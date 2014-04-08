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
  
  Point( float a, float b, float c, Point p1, Point p2, Point p3 )
  {
    m_p = new float[3];
    for (int i = 0; i < 3; i++)
    {
      m_p[i] = a*p1.get(i) + b*p2.get(i) + c*p3.get(i);
    }
  }
  
  public float X() { return m_p[0]; }
  public float Y() { return m_p[1]; }
  public float Z() { return m_p[2]; }
  public float get(int index)
  {
    return m_p[index];
  }
  public float[] get()
  {
    return m_p;
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

  public float getMagnitude()
  {
    return sqrt( getMagnitudeSquare() );
  }
  
  public float getMagnitudeSquare()
  {
    float[] val = new float[3];
    val[0] = m_p[0] * m_p[0];
    val[1] = m_p[1] * m_p[1];
    val[2] = m_p[2] * m_p[2];
    return val[0] + val[1] + val[2];
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
  
  public void add(Vector other)
  {   
    m_v[0] += other.m_v[0];
    m_v[1] += other.m_v[1];
    m_v[2] += other.m_v[2];
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
    //return invSqrt( getMagnitudeSquare() );
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
  private float m_time;
  
  //Ray differentials
  private Point[] m_deltaOrig;
  private Vector[] m_deltaDir;
  
  Ray(Point orig, Point other)
  {
    this( orig, other, true );
    m_time = 0;
    m_deltaOrig = null;
    m_deltaDir = null;
  }
  
  Ray(Point orig, Vector direction)
  {
    this( orig, direction, true );
    m_time = 0;
    m_deltaOrig = null;
    m_deltaDir = null;
  }
  
  Ray(Point orig, Point other, boolean fNormalize)
  {
    m_time = 0;
    m_orig = orig;
    m_dir = new Vector(orig, other);
    m_deltaOrig = null;
    m_deltaDir = null;
    if ( fNormalize )
    {
      m_dir.normalize();
    }
  }
  
  Ray(Point orig, Vector direction, boolean fNormalize)
  {
    m_time = 0;
    m_orig = orig;
    m_dir = direction;
    m_deltaOrig = null;
    m_deltaDir = null;
    if ( fNormalize )
    {
      m_dir.normalize();
    }
  }
  
  Ray reflect( Vector normal, Point point )
  {
    Vector direction = cloneVec( m_dir );
    Vector scaledNormal = cloneVec( normal );
    float projection = 2*direction.dot( normal );
    scaledNormal.scale( projection );
    direction.subtract( scaledNormal );
    Point displacedPoint = new Point( point, direction, 2*c_epsilon );
    return new Ray( displacedPoint, direction );
  }
  
  void setDifferentials( Point dx, Point dy, Vector dDirX, Vector dDirY )
  {
    m_deltaOrig = new Point[2];
    m_deltaDir = new Vector[2];
    m_deltaOrig[0] = dx; m_deltaOrig[1] = dy;
    m_deltaDir[0] = dDirX; m_deltaDir[1] = dDirY;
  }
  
  void updateDifferentialsTransfer( float t, Vector normal )
  {
    if (m_deltaOrig != null)
    { 
      Vector delPTDelDX =  new Vector(0,0,0);
      Vector delPTDelDY = new Vector(0,0,0);
      for (int i = 0; i < 3; i++)
      {
        delPTDelDX.set( i, m_deltaOrig[0].get(i) + t * m_deltaDir[0].get(i) );
        delPTDelDY.set( i, m_deltaOrig[1].get(i) + t * m_deltaDir[1].get(i) );
      }
      float delTDelX = -delPTDelDX.dot(normal) / m_dir.dot(normal);
      float delTDelY = -delPTDelDY.dot(normal) / m_dir.dot(normal);
      //float delTDelX = 0;
      //float delTDelY = 0;
      
      for (int i = 0; i < 3; i++)
      {
        m_deltaOrig[0].set( i, delPTDelDX.get(i) + delTDelX * m_dir.get(i) );
        m_deltaOrig[1].set( i, delPTDelDY.get(i) + delTDelY * m_dir.get(i) );
      }
      //print(t + " " + m_deltaOrig[0].X() + " " + m_deltaOrig[0].Y() + " " + m_deltaOrig[0].Z() + "    "); 
    }
  }
  
  void setTime( float time )
  {
    m_time = time;
  }
  
  float getTime()
  {
    return m_time;
  }

  Point getOrigin() { return m_orig; }
  
  Vector getDirection() { return m_dir; }
  
  Point getDeltaX() { if (m_deltaOrig == null) return null; return m_deltaOrig[0]; }
  Point getDeltaY() { if (m_deltaOrig == null) return null; return m_deltaOrig[1]; }
  Vector getDeltaDirX() { if (m_deltaDir == null) return null; return m_deltaDir[0]; }
  Vector getDeltaDirY() { if (m_deltaDir == null) return null; return m_deltaDir[1]; }
  Point getDelta(int index) { if (m_deltaOrig == null) return null; return m_deltaOrig[index]; }
  Vector getDeltaDir(int index) { if (m_deltaDir == null) return null; return m_deltaDir[index]; }
  
  void debugPrintDifferentials()
  {
    if ( count++ < 100 )
    {
      print("Begin Ray Differential : \n");
      m_deltaOrig[0].debugPrint();
      m_deltaOrig[1].debugPrint();
      m_deltaDir[0].debugPrint();
      m_deltaDir[1].debugPrint();
      print("End Ray Differential : \n");
    }
  }
  
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

