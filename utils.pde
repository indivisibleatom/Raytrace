float c_epsilon = 0.01;

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
  
  Point(Point init, Vector direction, float t)
  {
    m_x = init.X() + t * direction.X();
    m_y = init.Y() + t * direction.Y();
    m_z = init.Z() + t * direction.Z();
  }
  
  Point(Ray r, float t)
  {
    this(r.getOrigin(), r.getDirection(), t);
  }
  
  public float X() { return m_x; }
  public float Y() { return m_y; }
  public float Z() { return m_z; }
  
  void add( Vector direction, float t )
  {
    m_x += t * direction.X();
    m_y += t * direction.Y();
    m_z += t * direction.Z();
  }
    
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
  
  void debugPrint()
  {
    print( "Point : " + m_x + " " + m_y + " " + m_z + "\n" );
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
    m_x = pB.X() - pA.X();
    m_y = pB.Y() - pA.Y();
    m_z = pB.Z() - pA.Z();
  }
  
  public float X() { return m_x; }
  public float Y() { return m_y; }
  public float Z() { return m_z; }
  
  public float dot( Vector other )
  {
    return m_x * other.m_x + m_y * other.m_y + m_z * other.m_z;
  }
  
  public Vector cross( Vector other )
  {
    return new Vector( m_y * other.m_z - m_z * other.m_y, m_z * other.m_x - m_x * other.m_z, m_x * other.m_y - m_y * other.m_x );
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
    if ( denom != 0 )
    {
      m_x = m_x / denom;
      m_y = m_y / denom;
      m_z = m_z / denom;   
    }
  }
  
  void debugPrint()
  {
    print( "Vector : " + m_x + " " + m_y + " " + m_z + "\n" );
  }
}

Vector cloneVec(Vector other) { return new Vector(other); }

class Ray
{
  private Point m_orig;
  private Vector m_dir;
  
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
  
  Ray(Point orig, Vector direction)
  {
    m_orig = orig;
    m_dir = direction;
    m_dir.normalize();
  }
  
  Point getOrigin() { return m_orig; }
  
  Vector getDirection() { return m_dir; }
  
  void debugPrint()
  {
    print("Begin Ray : \n");
    print("Origin "); m_orig.debugPrint();
    print("Direction "); m_dir.debugPrint();
    print("End Ray \n");
  }
  
  public void advanceEpsilon()
  {
    m_orig.add( m_dir, c_epsilon );
  } 
}

class RayTransformFeedback
{
  private float m_scale;
  
  RayTransformFeedback()
  {
    m_scale = 1;
  }
  
  void setScale( float scale )
  {
    m_scale = scale;
  }
  
  float scale()
  {
    return m_scale;
  }
}

Ray clone(Ray other) { return new Ray(other); }

class Color
{
  private float m_r;
  private float m_g;
  private float m_b;
  
  private float clamp( float val )
  {
    val = val < 0 ? 0 : val;
    val = val > 1 ? 1 : val;
    return val;
  }
  
  Color(float r, float g, float b)
  {
    m_r = clamp(r);
    m_g = clamp(g);
    m_b = clamp(b);
  }
  
  Color(Color other)
  {
    m_r = other.m_r;
    m_g = other.m_g;
    m_b = other.m_b;
  }
  
  Color( float[] colors )
  {
    this(colors[0], colors[1], colors[2]);
    if ( colors.length != 3 )
    {
      if ( DEBUG && DEBUG_MODE >= LOW )
      {
        print ("Constructing colors from a coefficient array that is not size 4!!");
      }
    }
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
  
  public int getIntColor() 
  {
    int r = toInt(m_r);
    int g = toInt(m_g);
    int b = toInt(m_b);
    return ((r&0x0ff)<<16)|((g&0x0ff)<<8)|(b&0x0ff); 
  }
  
  public void add(Color other)
  {
    m_r = clamp( m_r + other.m_r );
    m_g = clamp( m_g + other.m_g );
    m_b = clamp( m_b + other.m_b );
  }
  
  public void scale(float scale)
  {
    m_r = clamp( m_r * scale );
    m_g = clamp( m_g * scale );
    m_b = clamp( m_b * scale );
  }

  public float R() { return m_r; }
  public float G() { return m_g; }
  public float B() { return m_b; } 
}

public Color combineColor(Color c1, Color c2)
{
  return new Color( c1.R() * c2.R(), c1.G() * c2.G(), c1.B() * c2.B() );
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
  
  void debugPrint()
  {
    print( "Rect : " + m_x + " " + m_y + " " + m_width + " " + m_height + "\n" );
  }
}

