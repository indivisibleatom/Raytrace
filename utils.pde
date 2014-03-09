float c_epsilon = 0.00001;
int count = 0;

public static float invSqrt(float x)
{
  float xhalf = 0.5f*x;
  int i = Float.floatToIntBits(x);
  i = 0x5f3759df - (i>>1);
  x = Float.intBitsToFloat(i);
  x *= (1.5f - xhalf*x*x);
  x *= (1.5f - xhalf*x*x);
  x *= (1.5f - xhalf*x*x);
  return x;
}

boolean compare( float n1, float n2 )
{
  return (abs(n1 - n2) < c_epsilon);
}

class Point
{
  private float[] m_p;

  Point(float x, float y, float z)
  {
    float[] p = {x, y, z};
    m_p = p;
  }
  
  Point(Point other)
  {
    float[] p = {other.m_p[0], other.m_p[1], other.m_p[2]};
    m_p = p;
  }
  
  Point(Point init, Vector direction, float t)
  {
    float[] p = { init.m_p[0], init.m_p[1], init.m_p[2] };
    p[0] += t * direction.m_v[0];
    p[1] += t * direction.m_v[1];
    p[2] += t * direction.m_v[2];
    m_p = p;
  }
  
  Point(float[] values)
  {
    m_p = values;
  }
  
  Point(Ray r, float t)
  {
    this(r.getOrigin(), r.getDirection(), t);
  }
  
  public float X() { return m_p[0]; }
  public float Y() { return m_p[1]; }
  public float Z() { return m_p[2]; }
  public float get(int index)
  {
    return m_p[index];
  }
  
  void add( Vector direction, float t )
  {
    m_p[0] += t * direction.m_v[0];
    m_p[1] += t * direction.m_v[1];
    m_p[2] += t * direction.m_v[2];
  }
    
  void subtract(Point other)
  {
    m_p[0] -= other.m_p[0];
    m_p[1] -= other.m_p[1];
    m_p[2] -= other.m_p[2];
  }
  
  void subtract(float[] values)
  {
    m_p[0] -= values[0];
    m_p[1] -= values[1];
    m_p[2] -= values[2];
  }
  
  void set( float x, float y, float z )
  {
    m_p[0] = x;
    m_p[1] = y;
    m_p[2] = z;
  }

  void set( int index, float value ) { m_p[index] = value; }
  void setX( float x ) { m_p[0] = x; }
  void setY( float y ) { m_p[1] = y; }
  void setZ( float z ) { m_p[2] = z; }
  
  void toNormalizedCoordinates(float scaleX, float scaleY, float scaleZ)
  {
    m_p[0] /= scaleX;
    m_p[1] /= scaleY;
    m_p[2] /= scaleZ;
  }
  
  float distanceFrom( Point other )
  {
    return sqrt( squaredDistanceFrom( other ) );
  }
  
  float squaredDistanceFrom( Point other )
  {
    return ( (m_p[0] - other.m_p[0])*(m_p[0] - other.m_p[0]) + (m_p[1] - other.m_p[1])*(m_p[1] - other.m_p[1]) + (m_p[2] - other.m_p[2])*(m_p[2] - other.m_p[2]) );
  }
  
  void debugPrint()
  {
    print( "Point : " + m_p[0] + " " + m_p[1] + " " + m_p[2] + "\n" );
  }
}

Point clonePt(Point other) { return new Point(other); }
final Point c_origin = new Point(0,0,0);

class Vector
{
  private float[] m_v;
  
  Vector(float x, float y, float z)
  {
    float[] v = {x, y, z, 0};
    m_v = v;
  } 
  
  Vector(Vector other)
  {
    float[] v = {other.m_v[0], other.m_v[1], other.m_v[2], other.m_v[3]};
    m_v = v;
  }
  
  Vector(float[] values)
  {
    m_v = values;
  }
  
  Vector(Point pA, Point pB)
  {
    float[] v = {pB.m_p[0] - pA.m_p[0], pB.m_p[1] - pA.m_p[1], pB.m_p[2] - pA.m_p[2], 0};
    m_v = v;
  }
  
  public float X() { return m_v[0]; }
  public float Y() { return m_v[1]; }
  public float Z() { return m_v[2]; }
  public float get(int index)
  {
    return m_v[index];
  }
  
  public void subtract(Vector other)
  {   
    m_v[0] -= other.m_v[0];
    m_v[1] -= other.m_v[1];
    m_v[2] -= other.m_v[2];
  }
  
  void set( int index, float value ) { m_v[index] = value; }
  void setX( float x ) { m_v[0] = x; }
  void setY( float y ) { m_v[1] = y; }
  void setZ( float z ) { m_v[2] = z; }
  
  public float dot( Vector other )
  {
    float[] val = new float[3];
    val[0] = m_v[0] * other.m_v[0];
    val[1] = m_v[1] * other.m_v[1];
    val[2] = m_v[2] * other.m_v[2];
    return val[0] + val[1] + val[2];
  }
  
  public Vector cross( Vector other )
  {
    return new Vector( m_v[1] * other.m_v[2] - m_v[2] * other.m_v[1], m_v[2] * other.m_v[0] - m_v[0] * other.m_v[2], m_v[0] * other.m_v[1] - m_v[1] * other.m_v[0] );
  }
  
  public float getMagnitude()
  {
    return sqrt( getMagnitudeSquare() );
  }
  
  public float getInvMagnitude()
  {
    return 1/getMagnitude();
  }
  
  public float getMagnitudeSquare()
  {
    return dot( this );
  }

  public void normalize()
  {
    float invDenom = getInvMagnitude();
    for (int i = 0; i < 3; i++)
    {
      m_v[i] *= invDenom;
    }
  }

  public void scale(float scale)
  {
    m_v[0] *= scale;
    m_v[1] *= scale;
    m_v[2] *= scale;
  }
  
  void debugPrint()
  {
    print( "Vector : " + m_v[0] + " " + m_v[1] + " " + m_v[2] + "\n" );
  }
}

Vector cloneVec(Vector other) { return new Vector(other); }

class Ray
{
  private Point m_orig;
  private Vector m_dir;
  
  Ray(Point orig, Point other)
  {
    this( orig, other, true );
  }
  
  Ray(Point orig, Vector direction)
  {
    this( orig, direction, true );
  }

  Ray(Point orig, Point other, boolean fNormalize)
  {
    m_orig = orig;
    m_dir = new Vector(orig, other);
    if ( fNormalize )
    {
      m_dir.normalize();
    }
  }
  
  Ray(Point orig, Vector direction, boolean fNormalize)
  {
    m_orig = orig;
    m_dir = direction;
    if ( fNormalize )
    {
      m_dir.normalize();
    }
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
 
  public void perturbDirection( int index )
  {
    m_dir.set( index, c_epsilon );
    m_dir.normalize();
  } 
}

class Color
{
  private float[] m_c;
  
  private float clamp( float val )
  {
    if ( val < 0 )
    {
      val = 0;
    }
    else if ( val > 1 )
    {
      val = 1;
    }
    return val;
  }
  
  private void clamp()
  {
    m_c[0] = clamp(m_c[0]);
    m_c[1] = clamp(m_c[1]);
    m_c[2] = clamp(m_c[2]);
  }
  
  Color(float r, float g, float b)
  {
    float[] c = { r, g, b };
    m_c = c;
    clamp();
  }
  
  Color(Color other)
  {
    float[] c = { other.m_c[0], other.m_c[1], other.m_c[2] };
    m_c = c;
  }
  
  Color( float[] colors )
  {
    m_c = colors;
    clamp();
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
    int r = toInt(m_c[0]);
    int g = toInt(m_c[1]);
    int b = toInt(m_c[2]);
    return ((r&0x0ff)<<16)|((g&0x0ff)<<8)|(b&0x0ff); 
  }
  
  public void add(Color other)
  {
    m_c[0] += other.m_c[0];
    m_c[1] += other.m_c[1];
    m_c[2] += other.m_c[2];
    clamp();
  }
  
  public void addUnclamped(Color other)
  {
    m_c[0] += other.m_c[0];
    m_c[1] += other.m_c[1];
    m_c[2] += other.m_c[2];
  }
  
  public void scale(float scale)
  {
    m_c[0] *= scale;
    m_c[1] *= scale;
    m_c[2] *= scale;
    clamp();
  }
  
  void debugPrint()
  {
    print("Begin Col : \n");
    print("Red, green, blue " + m_c[0] + " " + m_c[1] + " " + m_c[2] + "\n");
    print("End Col \n");
  }

  public float R() { return m_c[0]; }
  public float G() { return m_c[1]; }
  public float B() { return m_c[2]; } 
}

public Color combineColor(Color c1, Color c2)
{
  return new Color( c1.m_c[0] * c2.m_c[0], c1.m_c[1] * c2.m_c[1], c1.m_c[2] * c2.m_c[2] );
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

