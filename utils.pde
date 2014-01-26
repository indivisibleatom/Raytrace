class Point
{
  private float m_x;
  private float m_y;
  private float m_z;
  
  Point(float x, float y, float z)
  {
    m_x = x;
    m_y = y;
    m_z = z;
  }
  
  Point(Point other)
  {
    m_x = other.m_x;
    m_y = other.m_y;
    m_z = other.m_z;
  }
}

Point clone(Point other) { return new Point(other); }
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
  
  public void getMagnitude()
  {
    return sqrt( getMagnitudeSquare );
  }
  
  public void getMagnitudeSquare()
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

Vector clone(Vector other) { return new Vector(other); }

class Ray
{
  private Point m_orig;
  private Vector m_dir;
  
  Ray(Point orig, Vector dir)
  {
    m_orig  = clone(orig);
    m_dir = clone(dir);
    m_dir.normalize();
  }
  
  void getOrigin() { return m_orig; }
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
  
  public float R() { return m_r; }
  public float G() { return m_g; }
  public float B() { return m_b; }
}

Color clone(Color other) { return new Color(other); }

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
}

