///////////////////////////////////////////////////////////////////////
//
//  Ray Tracing Shell
//
///////////////////////////////////////////////////////////////////////

import java.nio.FloatBuffer;
import java.nio.IntBuffer;
import processing.opengl.*;   
import javax.media.opengl.GL2;

int screen_width = 300;
int screen_height = 300;

// the current active file name
SceneBuilder gCurrentFile;
PShader gShader;
PGraphicsOpenGL pgraphGl;
GL2 gl;
int location;
IntBuffer vaoHandle;

IntBuffer allocateDirectInt( int size )
{
  IntBuffer allocated = java.nio.ByteBuffer.allocateDirect(4 * size).asIntBuffer();
  return allocated;
}

FloatBuffer allocateDirectFloat( int size )
{
  FloatBuffer allocated = java.nio.ByteBuffer.allocateDirect(4 * size).asFloatBuffer();
  return allocated;
}

void setup() 
{
  size (screen_width, screen_height, OPENGL);  
  camera();
  noStroke();
  colorMode (RGB, 1.0);
  background (0, 0, 0);
  gShader = loadShader("fragment.frag", "vertex.vert");

  shader( gShader );
  pgraphGl = (PGraphicsOpenGL)g;
  gl = ((PJOGL)pgraphGl.pgl).gl.getGL2();

  float[] verticesF = {0,0,-1,screen_width,0,-1,0,screen_height,-1};
  FloatBuffer vertices = allocateDirectFloat( verticesF.length );
  vertices.put( verticesF );
  vertices.rewind();
  location = gl.glGetUniformLocation( gShader.glProgram, "vertices");
  gl.glUniform1fv(location, verticesF.length, vertices );

  location = gl.glGetAttribLocation( gShader.glProgram, "counter");
  int[] indicesI = {0, 1, 2};
  IntBuffer indices = allocateDirectInt( indicesI.length );
  indices.put( indicesI );
  indices.rewind();
  
  //Create the buffer objects
  vaoHandle = allocateDirectInt( 1 );
  IntBuffer vboHandleIndices = allocateDirectInt( 1 );  

  gl.glGenVertexArrays( 1, vaoHandle );
  gl.glBindVertexArray( vaoHandle.get(0) );

  gl.glGenBuffers( 1, vboHandleIndices );
  gl.glBindBuffer( gl.GL_ARRAY_BUFFER, vboHandleIndices.get(0) ); 
  gl.glBufferData( gl.GL_ARRAY_BUFFER, 4*indicesI.length, indices, gl.GL_STATIC_DRAW );

  gl.glEnableVertexAttribArray(location);
  gl.glVertexAttribPointer(location, 1, gl.GL_INT, false, 0, 0);
  gl.glBindVertexArray( 0 );
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
  background(0,0,0);
  fill(1,0,0);

  gl.glBindVertexArray( vaoHandle.get(0) );
  gl.glDrawElements( GL_TRIANGLES, 3, GL_UNSIGNED_BYTE, 
}

