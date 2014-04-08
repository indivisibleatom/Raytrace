///////////////////////////////////////////////////////////////////////
//
//  Ray Tracing Shell
//
///////////////////////////////////////////////////////////////////////


int screen_width = 600;
int screen_height = 600;

// the current active file name
SceneBuilder gCurrentFile;


// Some initializations for the scene.

void setup() {
  size (screen_width, screen_height);  
  noStroke();
  colorMode (RGB, 1.0);
  background (0, 0, 0);
  noLoop();
}

// Press key 1 to 9 and 0 to run different test cases.

void keyPressed() {
  switch(key) {
    case '0':  gCurrentFile = new SceneBuilder(); gCurrentFile.buildScene("t10.cli"); break;
    case '1':  gCurrentFile = new SceneBuilder(); gCurrentFile.buildScene("t01.cli"); break;
    case '2':  gCurrentFile = new SceneBuilder(); gCurrentFile.buildScene("t02.cli"); break;
    case '3':  gCurrentFile = new SceneBuilder(); gCurrentFile.buildScene("t03.cli"); break;
    case '4':  gCurrentFile = new SceneBuilder(); gCurrentFile.buildScene("t04.cli"); break;
    case '5':  gCurrentFile = new SceneBuilder(); gCurrentFile.buildScene("t05.cli"); break;
    case '6':  gCurrentFile = new SceneBuilder(); gCurrentFile.buildScene("t06.cli"); break;
    case '7':  gCurrentFile = new SceneBuilder(); gCurrentFile.buildScene("t07.cli"); break;
    case '8':  gCurrentFile = new SceneBuilder(); gCurrentFile.buildScene("t08.cli"); break;
    case '9':  gCurrentFile = new SceneBuilder(); gCurrentFile.buildScene("t09.cli"); break;
    case 'q':  exit(); break;
    case 'w':  g_scene.getCamera().moveForward();
  }
}

//  Parser core. It parses the CLI file and processes it based on each 
//  token. Only "color", "rect", and "write" tokens are implemented. 
//  You should start from here and add more functionalities for your
//  ray tracer.
//
//  Note: Function "splitToken()" is only available in processing 1.25 or higher.

//  Draw frames.  Should be left empty.
void draw() 
{
}

