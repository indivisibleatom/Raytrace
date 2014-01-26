///////////////////////////////////////////////////////////////////////
//
//  Ray Tracing Shell
//
///////////////////////////////////////////////////////////////////////

int screen_width = 300;
int screen_height = 300;

// the current active file name
SceneBuilder gCurrentFile;


// Some initializations for the scene.

void setup() {
  size (screen_width, screen_height);  
  noStroke();
  colorMode (RGB, 1.0);
  background (0, 0, 0);
}

/*void draw() {
  scene.draw();
}*/

// Press key 1 to 9 and 0 to run different test cases.

void keyPressed() {
  switch(key) {
    case '0':  gCurrentFile = new SceneBuilder("test.cli"); gCurrentFile.buildScene(); break;
    case '1':  gCurrentFile = new SceneBuilder("t0.cli"); gCurrentFile.buildScene(); break;
    case '2':  gCurrentFile = new SceneBuilder("t1.cli"); gCurrentFile.buildScene(); break;
    case '3':  gCurrentFile = new SceneBuilder("c0.cli"); gCurrentFile.buildScene(); break;
    case '4':  gCurrentFile = new SceneBuilder("c1.cli"); gCurrentFile.buildScene(); break;
    case '5':  gCurrentFile = new SceneBuilder("c2.cli"); gCurrentFile.buildScene(); break;
    case '6':  gCurrentFile = new SceneBuilder("c3.cli"); gCurrentFile.buildScene(); break;
  }
}

//  Parser core. It parses the CLI file and processes it based on each 
//  token. Only "color", "rect", and "write" tokens are implemented. 
//  You should start from here and add more functionalities for your
//  ray tracer.
//
//  Note: Function "splitToken()" is only available in processing 1.25 or higher.

//  Draw frames.  Should be left empty.
void draw() {
}

