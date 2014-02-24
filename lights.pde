interface Light extends Primitive
{
  //Get a ray from the passed in point to the light
  Ray getRay( Point fromFrom );
  Color getColor();
}

class PointLight implements Light
{
  private Point m_position;
  private Color m_color;
  
  PointLight( Point position, Color col )
  {
    m_position = position;
    m_color = col;
  }

  public boolean intersects( Ray ray, float tMin, float tMax )
  {
    return false;
  }
  
  public IntersectionInfo getIntersectionInfo( Ray ray, float tMin, float tMax )
  {
    return null;
  }
  
  public Color getColor()
  {
    return m_color;
  }
  
  public Ray getRay( Point pointFrom )
  {
    return new Ray( pointFrom, new Vector( pointFrom, m_position ) );
  }
  
  public Vector getNormal()
  {
    return null;
  }
}

