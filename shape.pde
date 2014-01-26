interface Shape
{
  public boolean intersects( Ray ray );
  public IntersectionInfo getIntersectionInfo( Ray ray );
}

class Sphere implements Shape
{
  private float m_radius;
  private Point m_center;
  
  Sphere( float radius, Point center )
  {
    m_radius = radius;
    m_center = center;
  }
}

class Triangle implements Shape
{
  private Point[3] m_vertices;
  
  Triangle( Point[3] vertices )
  {
    for (int i = 0; i < 3; i++)
    {
      m_vertices[i] = clone(vertices[i]);
    }
  }
}

