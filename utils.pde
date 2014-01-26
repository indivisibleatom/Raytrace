class Point
{
  private float m_x;
  private float m_y;
  private float m_z;
  
  Point(float x, float y, float z)
  {
    set(x, y, z);
  }
  
  Point(Point other)
  {
    m_x = other.m_x;
    m_y = other.m_y;
    m_z = other.m_z;
  }
  
  public float X() { return m_x; }
  public float Y() { return m_y; }
  public float Z() { return m_z; }
  
  void subtract(Point other)
  {
    m_x -= other.m_x;
    m_y -= other.m_y;
    m_z -= other.m_z;
  }
  
  void set( float x, float y, float z )
  {
    m_x = x;
    m_y = y;
    m_z = z;
  }
  
  void toNormalizedCoordinates(float scaleX, float scaleY, float scaleZ)
  {
    m_x /= scaleX;
    m_y /= scaleY;
    m_z /= scaleZ;
  }
}

Point clonePt(Point other) { return new Point(other); }
final Point c_origin = new Point(0,0,0);

class Vector
{
  private float m_x;
  private float m_y;
  private float m_z;
  
  Vector(float x, float y, float z)
  {
    m_x = x;
    m_y = y;
    m_z = z;
  } 
  
  Vector(Vector other)
  {
    m_x = other.m_x;
    m_y = other.m_y;
    m_z = other.m_z;
  }
  
  Vector(Point pA, Point pB)
  {
    m_x = pB.m_x - pA.m_x;
    m_y = pB.m_y - pA.m_y;
    m_z = pB.m_z - pA.m_z;
  }
  
  public float dot( Vector other )
  {
    return m_x * other.m_x + m_y * other.m_y + m_z + other.m_z;
  }
  
  public float getMagnitude()
  {
    return sqrt( getMagnitudeSquare() );
  }
  
  public float getMagnitudeSquare()
  {
    return dot( this );
  }

  public void normalize()
  {
    float denom = getMagnitude();
    m_x = m_x / denom;
    m_y = m_y / denom;
    m_z = m_z / denom;   
  }
}

Vector cloneVec(Vector other) { return new Vector(other); }

class Ray
{
  private Point m_orig;
  private Vector m_dir;
  
  Ray(Point orig, Vector dir)
  {
    m_orig  = clonePt(orig);
    m_dir = cloneVec(dir);
    m_dir.normalize();
  }
  
  Ray(Ray other)
  {
    m_orig  = clonePt(other.m_orig);
    m_dir = cloneVec(other.m_dir);
  }
  
  Ray(Point orig, Point other)
  {
    m_orig = orig;
    m_dir = new Vector(orig, other);
    m_dir.normalize();
  }
  
  Point getOrigin() { return m_orig; }
  
  Vector getDirection() { return m_dir; }
}

Ray clone(Ray other) { return new Ray(other); }

Vector clone(Vector other) { return new Vector(other); }

class Color
{
  private float m_r;
  private float m_g;
  private float m_b;
  
  Color(float r, float g, float b)
  {
    m_r = r;
    m_g = g;
    m_b = b;
  }
  
  Color(Color other)
  {
    m_r = other.m_r;
    m_g = other.m_g;
    m_b = other.m_b;
  }
  
  private int toInt( float f )
  {
    int retVal;
    retVal = (int) (f*256.0);
    if ( retVal >= 255 )
    {
      retVal = 255;
    }
    return retVal;
  }
  
  int getIntColor() 
  {
    int r = toInt(m_r);
    int g = toInt(m_g);
    int b = toInt(m_b);
    return ((r&0x0ff)<<16)|((g&0x0ff)<<8)|(b&0x0ff); 
  }

  public float R() { return m_r; }
  public float G() { return m_g; }
  public float B() { return m_b; }
}

Color cloneCol(Color other) { return new Color(other); }

class Rect
{
  private int m_x;
  private int m_y;
  private int m_width;
  private int m_height;
  
  Rect(int x, int y, int width, int height)
  {
    m_x = x;
    m_y = y;
    m_width = width;
    m_height = height;
  }
  
  public int X() { return m_x; }
  public int Y() { return m_y; }
  public int width() { return m_width; }
  public int height() { return m_height; }
}

