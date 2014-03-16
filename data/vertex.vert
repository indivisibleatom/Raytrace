#version 130

#define PROCESSING_COLOR_SHADER

uniform mat4 transform;
uniform float vertices[9];

in vec4 vertex;
in vec4 color;
in int counter;

out vec4 vertColor;

void main()
{
    //vec4 vert = vec4(vertices[3*counter], vertices[3*counter+1], vertices[3*counter+2], vertex.w);
    vec4 vert = vec4(vertex.x, vertex.y, vertex.z, vertex.w);
    gl_Position = transform * vert;
    if ( counter == 0 )
    {
        vertColor = vec4(0,0,1,1);
    }
    else
    { 
        vertColor = vec4(1,1,0,1);
    }
}
