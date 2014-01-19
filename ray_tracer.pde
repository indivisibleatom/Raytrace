///////////////////////////////////////////////////////////////////////
//
//  Ray Tracing Shell
//
///////////////////////////////////////////////////////////////////////

int screen_width = 300;
int screen_height = 300;

// the current active file name
String gCurrentFile = new String("rect_test.cli");   


// Some initializations for the scene.

void setup() {
  size (screen_width, screen_height);  
  noStroke();
  colorMode (RGB, 1.0);
  background (0, 0, 0);
  interpreter();
}

// Press key 1 to 9 and 0 to run different test cases.

void keyPressed() {
  switch(key) {
    case '1':  gCurrentFile = new String("t0.cli"); interpreter(); break;
    case '2':  gCurrentFile = new String("t1.cli"); interpreter(); break;
    case '3':  gCurrentFile = new String("c0.cli"); interpreter(); break;
    case '4':  gCurrentFile = new String("c1.cli"); interpreter(); break;
    case '5':  gCurrentFile = new String("c2.cli"); interpreter(); break;
    case '6':  gCurrentFile = new String("c3.cli"); interpreter(); break;
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

