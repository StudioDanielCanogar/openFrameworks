#include "ofAppSDLWindow.h"

#if defined(TARGET_SDL_WINDOW)

	#include "ofGLProgrammableRenderer.h"
	#include "ofGLRenderer.h"

	#include <SDL3/SDL.h>

#ifndef TARGET_OPENGLES
	#include <GL/glew.h>
#endif

using std::shared_ptr;

//-------------------------------------------------------
ofAppSDLWindow::ofAppSDLWindow()
	: coreEvents(new ofCoreEvents) {
	// register this instance as the current one for static callbacks
	currentWindowInstance = this;
}

ofAppSDLWindow::~ofAppSDLWindow() {
	close();
	// clear the static pointer if this instance was current
	if (currentWindowInstance == this) {
		currentWindowInstance = nullptr;
	}
}

void ofAppSDLWindow::close() {
	if (windowP) {
		currentRenderer.reset();
		SDL_DestroyWindow(windowP);
		windowP = nullptr;
		events().disable();
	}
}

	#ifdef TARGET_OPENGLES
void ofAppSDLWindow::setup(const ofGLESWindowSettings & settings) {
	#else
void ofAppSDLWindow::setup(const ofGLWindowSettings & settings) {
	#endif
	const ofSDLWindowSettings * sdlSettings = dynamic_cast<const ofSDLWindowSettings *>(&settings);
	if (sdlSettings) {
		setup(*sdlSettings);
	} else {
		setup(ofSDLWindowSettings(settings));
	}
}

void ofAppSDLWindow::setup(const ofSDLWindowSettings & _settings) {
	settings = _settings;

	if (!SDL_Init(SDL_INIT_VIDEO)) {
		const char * err = SDL_GetError();
		ofLogError("ofAppSDLWindow") << "couldn't init SDL video: " << err;
		std::cerr << "SDL_INIT_VIDEO failed: " << (err ? err : "(null)") << std::endl;
		return;
	}
	Uint32 flags = SDL_WINDOW_OPENGL;
	if (settings.resizable) flags |= SDL_WINDOW_RESIZABLE;
	if (!settings.visible) flags |= SDL_WINDOW_HIDDEN;
	if (settings.fullscreen) flags |= SDL_WINDOW_FULLSCREEN;
	if (settings.maximized) flags |= SDL_WINDOW_MAXIMIZED;

	#ifdef __APPLE__
	// macOS requires a core profile for modern GL
	SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);
	#endif

	SDL_GL_SetAttribute(SDL_GL_RED_SIZE, 8);
	SDL_GL_SetAttribute(SDL_GL_GREEN_SIZE, 8);
	SDL_GL_SetAttribute(SDL_GL_BLUE_SIZE, 8);
	SDL_GL_SetAttribute(SDL_GL_ALPHA_SIZE, 8);
	SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 24);
	SDL_GL_SetAttribute(SDL_GL_STENCIL_SIZE, 0);
	SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, settings.doubleBuffering ? 1 : 0);
	SDL_GL_SetAttribute(SDL_GL_MULTISAMPLEBUFFERS, settings.numSamples > 0 ? 1 : 0);
	SDL_GL_SetAttribute(SDL_GL_MULTISAMPLESAMPLES, settings.numSamples);

	#ifndef TARGET_OPENGLES
	SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, settings.glVersionMajor);
	SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, settings.glVersionMinor);
	#else
	SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, settings.glesVersion);
	SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 0);
	#endif

	windowP = SDL_CreateWindow(settings.title.c_str(), settings.getWidth(), settings.getHeight(), flags);

	if (!windowP) {
		ofLogError("ofAppSDLWindow") << "couldn't create SDL window: " << SDL_GetError();
		return;
	}
	currentW = windowW = settings.getWidth();
	currentH = windowH = settings.getHeight();

	#ifndef TARGET_OPENGLES
	SDL_GLContext context = SDL_GL_CreateContext(windowP);
	if (!context) {
		ofLogError("ofAppSDLWindow") << "couldn't create GL context: " << SDL_GetError();
		const char * err = SDL_GetError();
		std::cerr << "SDL_GL_CreateContext failed: " << (err ? err : "(null)") << std::endl;
		return;
	}
	if (!SDL_GL_MakeCurrent(windowP, context)) {
		ofLogError("ofAppSDLWindow") << "SDL_GL_MakeCurrent failed: " << SDL_GetError();
		return;
	}

	// Initialize GLEW once after a valid context exists, like the GLFW backend
	static bool glewInited = false;
	if (!glewInited) {
		glewExperimental = GL_TRUE;
		GLenum err = glewInit();
		if (GLEW_OK != err) {
			ofLogError("ofAppSDLWindow") << "couldn't init GLEW: " << glewGetErrorString(err);
			return;
		}
		glewInited = true;
	}

	// Log GL version and ensure context is valid before creating renderer
	const GLubyte * verStr = glGetString(GL_VERSION);
	if (!verStr) {
		ofLogError("ofAppSDLWindow") << "glGetString(GL_VERSION) returned null; GL context is not valid";
	} else {
		ofLogNotice("ofAppSDLWindow") << "GL_VERSION: " << (const char *)verStr;
	}
	int gotMajor = 0, gotMinor = 0;
	SDL_GL_GetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, &gotMajor);
	SDL_GL_GetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, &gotMinor);
	ofLogNotice("ofAppSDLWindow") << "SDL GL context version " << gotMajor << "." << gotMinor;
	#endif

	#ifndef TARGET_OPENGLES
	// Decide renderer shader version, clamping if needed
	int rendererMajor = settings.glVersionMajor;
	int rendererMinor = settings.glVersionMinor;
	if (rendererMajor == 0) {
		int gotMajor = 0, gotMinor = 0;
		SDL_GL_GetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, &gotMajor);
		SDL_GL_GetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, &gotMinor);
		if (gotMajor > 0) {
			rendererMajor = gotMajor;
			rendererMinor = gotMinor;
		} else {
			rendererMajor = 3;
			rendererMinor = 2;
		}
	}
	// #ifdef __APPLE__
	// Be conservative for OF shaders on macOS: clamp 4.x down to 3.2
	// if (rendererMajor >= 4) {
	// 	rendererMajor = 3;
	// 	rendererMinor = 2;
	// }
	// #endif

	if (rendererMajor >= 3) {
		currentRenderer = std::make_shared<ofGLProgrammableRenderer>(this);
		static_cast<ofGLProgrammableRenderer *>(currentRenderer.get())->setup(rendererMajor, rendererMinor);
	} else {
		currentRenderer = std::make_shared<ofGLRenderer>(this);
		static_cast<ofGLRenderer *>(currentRenderer.get())->setup();
	}
	#else
	if (settings.glesVersion >= 2) {
		currentRenderer = std::make_shared<ofGLProgrammableRenderer>(this);
		static_cast<ofGLProgrammableRenderer *>(currentRenderer.get())->setup(settings.glesVersion, 0);
	} else {
		currentRenderer = std::make_shared<ofGLRenderer>(this);
		static_cast<ofGLRenderer *>(currentRenderer.get())->setup();
	}
	#endif


}

//------------------------------------------------------------
ofCoreEvents & ofAppSDLWindow::events() {
	return *coreEvents;
}

shared_ptr<ofBaseRenderer> & ofAppSDLWindow::renderer() {
	return currentRenderer;
}

void ofAppSDLWindow::update() {
	events().notifyUpdate();
}

void ofAppSDLWindow::draw() {
	if (!currentRenderer) return;

	currentRenderer->startRender();
	if (bEnableSetupScreen) currentRenderer->setupScreen();

	events().notifyDraw();

	if (settings.doubleBuffering) {
		SDL_GL_SwapWindow(windowP);
	} else {
		glFlush();
	}

	currentRenderer->finishRender();
}

bool ofAppSDLWindow::getWindowShouldClose() {
	// SDL uses events; this window itself has no should-close flag
	return false;
}

void ofAppSDLWindow::setWindowShouldClose() {
	// user should post an SDL_QUIT event from outside
}

void ofAppSDLWindow::hideCursor() {
	SDL_HideCursor();
}

void ofAppSDLWindow::showCursor() {
	SDL_ShowCursor();
}

int ofAppSDLWindow::getWidth() {
	return currentW;
}

int ofAppSDLWindow::getHeight() {
	return currentH;
}

glm::vec2 ofAppSDLWindow::getWindowSize() {
	return { currentW, currentH };
}

// TODO: ofAppSDLWindow::getScreenSize
glm::vec2 ofAppSDLWindow::getScreenSize() {
	//    SDL_DisplayMode mode;
	// SDL_DisplayID
	//    if(SDL_GetCurrentDisplayMode(0, &mode) == 0){
	//        return { mode.w, mode.h };
	//    }
	return { currentW, currentH };
}

glm::vec2 ofAppSDLWindow::getWindowPosition() {
	int x = 0, y = 0;
	SDL_GetWindowPosition(windowP, &x, &y);
	return { x, y };
}

void ofAppSDLWindow::setWindowTitle(std::string title) {
	settings.title = title;
	if (windowP) SDL_SetWindowTitle(windowP, title.c_str());
}

void ofAppSDLWindow::setWindowPosition(int x, int y) {
	if (windowP) SDL_SetWindowPosition(windowP, x, y);
}

void ofAppSDLWindow::setWindowShape(int w, int h) {
	if (windowP) SDL_SetWindowSize(windowP, w, h);
	currentW = w;
	currentH = h;
}

void ofAppSDLWindow::setOrientation(ofOrientation _orientation) {
	orientation = _orientation;
}

ofOrientation ofAppSDLWindow::getOrientation() {
	return orientation;
}

ofWindowMode ofAppSDLWindow::getWindowMode() {
	return targetWindowMode;
}

void ofAppSDLWindow::setFullscreen(bool fullscreen) {
	targetWindowMode = fullscreen ? OF_FULLSCREEN : OF_WINDOW;
	if (windowP) {
		SDL_SetWindowFullscreen(windowP, fullscreen ? SDL_WINDOW_FULLSCREEN : 0);
	}
}

void ofAppSDLWindow::toggleFullscreen() {
	setFullscreen(targetWindowMode != OF_FULLSCREEN);
}

void ofAppSDLWindow::enableSetupScreen() {
	bEnableSetupScreen = true;
}

void ofAppSDLWindow::disableSetupScreen() {
	bEnableSetupScreen = false;
}

void ofAppSDLWindow::setVerticalSync(bool bSync) {
	SDL_GL_SetSwapInterval(bSync ? 1 : 0);
}

void ofAppSDLWindow::makeCurrent() {
	// assuming a single context bound to windowP
}

void ofAppSDLWindow::swapBuffers() {
	if (windowP) SDL_GL_SwapWindow(windowP);
}

void ofAppSDLWindow::startRender() {
	if (currentRenderer) currentRenderer->startRender();
}

void ofAppSDLWindow::finishRender() {
	if (currentRenderer) currentRenderer->finishRender();
}

void ofAppSDLWindow::pollEvents() {
	// static callback: operate on the current instance, if any
	if (!currentWindowInstance) {
		return;
	}

	SDL_Event event;
	while (SDL_PollEvent(&event)) {
		switch (event.type) {
		case SDL_EVENT_WINDOW_RESIZED:
			currentWindowInstance->currentW = event.window.data1;
			currentWindowInstance->currentH = event.window.data2;
			break;
		}
	}
}

SDL_Window * ofAppSDLWindow::getSDLWindow() {
	return windowP;
}

// define static member
ofAppSDLWindow * ofAppSDLWindow::currentWindowInstance = nullptr;

#endif // TARGET_SDL_WINDOW
