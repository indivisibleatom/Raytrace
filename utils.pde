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
}

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
}

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

