//
// Created by Cristobal Mendoza on 12/1/25.
//

#include "ofAppSDLWindow.h"

#include "ofLog.h"
void ofAppSDLWindow::setup(const ofWindowSettings & _settings) {
	const ofSDLWindowSettings * glSettings = dynamic_cast<const ofSDLWindowSettings *>(&_settings);
	if (glSettings) {
		setup(*glSettings);
	} else {
		setup(ofSDLWindowSettings(_settings));
	}
}

void ofAppSDLWindow::setup(const ofSDLWindowSettings & _settngs) {
	if (window != nullptr) {
		ofLogError() << "window already setup, probably you are mixing old and new style setup";
		ofLogError() << "call only ofCreateWindow(settings) or ofSetupOpenGL(...)";
		ofLogError() << "calling window->setup() after ofCreateWindow() is not necessary and won't do anything";
		return;
	}

	settings = _settngs;

	auto initFlags = SDL_WasInit(SDL_INIT_VIDEO | SDL_INIT_EVENTS);

	if (!(initFlags & SDL_INIT_VIDEO)) {
		if (!SDL_InitSubSystem(SDL_INIT_VIDEO)) {
			ofLogError("ofAppSDLWindow") << "SDL_InitSubSystem(SDL_INIT_VIDEO) failed";
			return;
		}
	}

	if (!(initFlags & SDL_INIT_EVENTS)) {
		if (!SDL_InitSubSystem(SDL_INIT_EVENTS)) {
			ofLogError("ofAppSDLWindow") << "SDL_InitSubSystem(SDL_INIT_EVENTS) failed";
			return;
		}
	}

	// Create an application window with the following settings:
	window = SDL_CreateWindow(
		settings.title.c_str(),                  // window title
		settings.getWidth(),                               // width, in pixels
		settings.getHeight(),                               // height, in pixels
		SDL_WINDOW_OPENGL| SDL_WINDOW_RESIZABLE
	);

	if (window == nullptr) {
		ofLogError("ofAppSDLWindow") << "SDL_CreateWindow() failed: " << SDL_GetError();
		return;
	}
	

}
void ofAppSDLWindow::update() {
}
void ofAppSDLWindow::draw() {
}
ofCoreEvents & ofAppSDLWindow::events() {
}
std::shared_ptr<ofBaseRenderer> & ofAppSDLWindow::renderer() {
}
ofAppSDLWindow::~ofAppSDLWindow() {
}
bool ofAppSDLWindow::getWindowShouldClose() {
	return ofAppBaseWindow::getWindowShouldClose();
}
void ofAppSDLWindow::setWindowShouldClose() {
	ofAppBaseWindow::setWindowShouldClose();
}
void ofAppSDLWindow::close() {
	ofAppBaseWindow::close();
}
void ofAppSDLWindow::hideCursor() {
	ofAppBaseWindow::hideCursor();
}
void ofAppSDLWindow::showCursor() {
	ofAppBaseWindow::showCursor();
}
void ofAppSDLWindow::setWindowPosition(int x, int y) {
	ofAppBaseWindow::setWindowPosition(x, y);
}
void ofAppSDLWindow::setWindowShape(int w, int h) {
	ofAppBaseWindow::setWindowShape(w, h);
}
glm::vec2 ofAppSDLWindow::getWindowPosition() {
	return ofAppBaseWindow::getWindowPosition();
}
glm::vec2 ofAppSDLWindow::getWindowSize() {
	return ofAppBaseWindow::getWindowSize();
}
glm::vec2 ofAppSDLWindow::getScreenSize() {
	return ofAppBaseWindow::getScreenSize();
}
void ofAppSDLWindow::setOrientation(ofOrientation orientation) {
	ofAppBaseWindow::setOrientation(orientation);
}
ofOrientation ofAppSDLWindow::getOrientation() {
	return ofAppBaseWindow::getOrientation();
}
bool ofAppSDLWindow::doesHWOrientation() {
	return ofAppBaseWindow::doesHWOrientation();
}
int ofAppSDLWindow::getWidth() {
	return ofAppBaseWindow::getWidth();
}
int ofAppSDLWindow::getHeight() {
	return ofAppBaseWindow::getHeight();
}
void ofAppSDLWindow::setWindowTitle(std::string title) {
	ofAppBaseWindow::setWindowTitle(title);
}
ofWindowMode ofAppSDLWindow::getWindowMode() {
	return ofAppBaseWindow::getWindowMode();
}
void ofAppSDLWindow::setFullscreen(bool fullscreen) {
	ofAppBaseWindow::setFullscreen(fullscreen);
}
void ofAppSDLWindow::toggleFullscreen() {
	ofAppBaseWindow::toggleFullscreen();
}
void ofAppSDLWindow::setVerticalSync(bool enabled) {
	ofAppBaseWindow::setVerticalSync(enabled);
}
void ofAppSDLWindow::makeCurrent() {
	ofAppBaseWindow::makeCurrent();
}
void ofAppSDLWindow::swapBuffers() {
	ofAppBaseWindow::swapBuffers();
}
void ofAppSDLWindow::startRender() {
	ofAppBaseWindow::startRender();
}
void ofAppSDLWindow::finishRender() {
	ofAppBaseWindow::finishRender();
}
void * ofAppSDLWindow::getWindowContext() {
	return ofAppBaseWindow::getWindowContext();
}