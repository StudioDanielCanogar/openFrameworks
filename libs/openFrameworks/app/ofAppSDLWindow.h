//
// Created by Cristobal Mendoza on 12/1/25.
//

#pragma once
#include "SDL3/SDL.h"
#include "ofAppBaseWindow.h"
#include "ofRectangle.h"

class ofSDLWindowSettings : public ofGLWindowSettings {
public:
	ofSDLWindowSettings() = default;

	explicit ofSDLWindowSettings(const ofGLWindowSettings & settings)
		: ofGLWindowSettings(settings) { }

#ifdef TARGET_RASPBERRY_PI
	int numSamples = 0;
#else
	int numSamples = 4;
#endif

	bool doubleBuffering = true;
	int redBits = 8;
	int greenBits = 8;
	int blueBits = 8;
	int alphaBits = 8;
	int depthBits = 24;
	int stencilBits = 0;
	bool stereo = false;
	bool visible = true;
	bool iconified = false;
	bool decorated = true;
	bool floating = false;
	bool resizable = true;
	bool transparent = false;
	bool mousePassThrough = false;
	bool maximized = false;
	int monitor = 0;
	bool multiMonitorFullScreen = false;
	std::shared_ptr<ofAppBaseWindow> shareContextWith;
};

class ofAppSDLWindow : public ofAppBaseWindow {
public:
	void setup(const ofWindowSettings & _settings) override;
	void setup(const ofSDLWindowSettings & settngs);
	void update() override;
	void draw() override;
	ofCoreEvents & events() override;
	std::shared_ptr<ofBaseRenderer> & renderer() override;
	~ofAppSDLWindow() override;
	bool getWindowShouldClose() override;
	void setWindowShouldClose() override;
	void close() override;
	void hideCursor() override;
	void showCursor() override;
	void setWindowPosition(int x, int y) override;
	void setWindowShape(int w, int h) override;
	glm::vec2 getWindowPosition() override;
	glm::vec2 getWindowSize() override;
	glm::vec2 getScreenSize() override;
	void setOrientation(ofOrientation orientation) override;
	ofOrientation getOrientation() override;
	bool doesHWOrientation() override;
	int getWidth() override;
	int getHeight() override;
	void setWindowTitle(std::string title) override;
	ofWindowMode getWindowMode() override;
	void setFullscreen(bool fullscreen) override;
	void toggleFullscreen() override;
	void setVerticalSync(bool enabled) override;
	void makeCurrent() override;
	void swapBuffers() override;
	void startRender() override;
	void finishRender() override;
	void * getWindowContext() override;

private:
	SDL_Window * window = nullptr;
	std::unique_ptr<ofCoreEvents> coreEvents;
	std::shared_ptr<ofBaseRenderer> currentRenderer;
	ofSDLWindowSettings settings;

	ofWindowMode targetWindowMode = ofWindowMode::OF_WINDOW;

	int windowW, windowH; /// Physical framebuffer pixels extents
	int currentW, currentH; /// Extents of the window client area, which may be scaled by pixelsScreenCoordScale to map to physical framebuffer pixels.
	float pixelScreenCoordScale; /// Scale factor from virtual operating-system defined client area extents (as seen in currentW, currentH) to physical framebuffer pixel coordinates (as seen in windowW, windowH).

	ofRectangle windowRect;

	int buttonInUse;
	bool buttonPressed;

	int nFramesSinceWindowResized;
	bool bWindowNeedsShowing;

	ofBaseApp * ofAppPtr;

	ofOrientation orientation;

};
