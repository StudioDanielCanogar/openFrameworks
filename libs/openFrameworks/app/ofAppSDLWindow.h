#pragma once

#include "ofAppBaseWindow.h"
#include "ofRectangle.h"
#include "ofConstants.h"

#if defined(TARGET_SDL_WINDOW)

class ofBaseApp;
struct SDL_Window;
class ofCoreEvents;

#ifdef TARGET_OPENGLES
class ofSDLWindowSettings : public ofGLESWindowSettings {
#else
class ofSDLWindowSettings : public ofGLWindowSettings {
#endif
public:
    ofSDLWindowSettings() {}

#ifdef TARGET_OPENGLES
    ofSDLWindowSettings(const ofGLESWindowSettings & settings)
    : ofGLESWindowSettings(settings) {}
#else
    ofSDLWindowSettings(const ofGLWindowSettings & settings)
    : ofGLWindowSettings(settings) {}
#endif

    int numSamples = 4;
    bool doubleBuffering = true;
    bool visible = true;
    bool resizable = true;
    bool decorated = true;
    bool fullscreen = false;
    bool maximized = false;
};

#ifdef TARGET_OPENGLES
class ofAppSDLWindow : public ofAppBaseGLESWindow {
#else
class ofAppSDLWindow : public ofAppBaseGLWindow {
#endif
public:
    ofAppSDLWindow();
    virtual ~ofAppSDLWindow();

    ofAppSDLWindow(ofAppSDLWindow&) = delete;
    ofAppSDLWindow& operator=(ofAppSDLWindow&) = delete;

    static void loop() {}
    static bool doesLoop() { return false; }
    static bool allowsMultiWindow() { return true; }
    static bool needsPolling() { return true; }
    static void pollEvents();

    using ofAppBaseWindow::setup;
#ifdef TARGET_OPENGLES
    void setup(const ofGLESWindowSettings & settings);
#else
    void setup(const ofGLWindowSettings & settings);
#endif
    void setup(const ofSDLWindowSettings & settings);

    void update();
    void draw();

    bool getWindowShouldClose();
    void setWindowShouldClose();

    void hideCursor();
    void showCursor();

    int getWidth();
    int getHeight();

    ofCoreEvents & events();
    std::shared_ptr<ofBaseRenderer> & renderer();

    SDL_Window * getSDLWindow();
    void * getWindowContext() override { return getSDLWindow(); }

    glm::vec2 getWindowSize() override;
    glm::vec2 getScreenSize() override;
    glm::vec2 getWindowPosition() override;

    void setWindowTitle(std::string title) override;
    void setWindowPosition(int x, int y) override;
    void setWindowShape(int w, int h) override;

    void setOrientation(ofOrientation orientation) override;
    ofOrientation getOrientation() override;

    ofWindowMode getWindowMode() override;

    void setFullscreen(bool fullscreen) override;
    void toggleFullscreen() override;

    void enableSetupScreen() override;
    void disableSetupScreen() override;

    void setVerticalSync(bool bSync) override;

    void makeCurrent() override;
    void swapBuffers() override;
    void startRender() override;
    void finishRender() override;

private:
    void close() override;

    std::unique_ptr<ofCoreEvents> coreEvents;
    std::shared_ptr<ofBaseRenderer> currentRenderer;
    ofSDLWindowSettings settings;

    ofWindowMode targetWindowMode;

    bool bEnableSetupScreen = true;
    int windowW = 0;
    int windowH = 0;
    int currentW = 0;
    int currentH = 0;

    ofRectangle windowRect;

    SDL_Window * windowP = nullptr;

    ofBaseApp * ofAppPtr = nullptr;
    ofOrientation orientation = OF_ORIENTATION_DEFAULT;

    // single active instance used by static callbacks like pollEvents
    static ofAppSDLWindow * currentWindowInstance;
};

#endif // TARGET_SDL_WINDOW

