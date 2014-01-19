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

void interpreter() {
  
  String str[] = loadStrings(gCurrentFile);
  if (str == null) println("Error! Failed to read the file.");
  for (int i=0; i<str.length; i++) {
    
    String[] token = splitTokens(str[i], " "); // Get a line and parse tokens.
    if (token.length == 0) continue; // Skip blank line.
    
    if (token[0].equals("fov")) {
      // TODO
    }
    else if (token[0].equals("background")) {
      // TODO
    }
    else if (token[0].equals("point_light")) {
      // TODO
    }
    else if (token[0].equals("surface")) {
      // TODO
    }    
    else if (token[0].equals("begin")) {
      // TODO
    }
    else if (token[0].equals("end")) {
      // TODO
    }
    else if (token[0].equals("vertex")) {
      // TODO
    }
    else if (token[0].equals("sphere")) {
      // TODO
    }
    else if (token[0].equals("color")) {
      float r = float(token[1]);
      float g = float(token[2]);
      float b = float(token[3]);
      fill(r, g, b);
    }
    else if (token[0].equals("rect")) {
      float x0 = float(token[1]);
      float y0 = float(token[2]);
      float x1 = float(token[3]);
      float y1 = float(token[4]);
      rect(x0, screen_height-y1, x1-x0, y1-y0);
    }
    else if (token[0].equals("write")) {
      // save the current image to a .png file
      save(token[1]);  
    }
  }
}

//  Draw frames.  Should be left empty.
void draw() {
}

