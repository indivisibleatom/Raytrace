interface Shape
{
  public boolean intersects( Ray ray );
  //public IntersectionInfo getIntersectionInfo( Ray ray );
}

class Sphere implements Shape
{
  Transformation m_transformation;

  Sphere( Transformation transformation )
  {
    m_transformation = transformation;
  }
  
  Sphere( float radius, Point center, Transformation transformation )
  {
    m_transformation = new Transformation();
    m_transformation.apply( transformation );
    m_transformation.translate( new Vector( c_origin, center ) );
    m_transformation.scale( radius );
  }
  
  private boolean intersectsCanonical( Ray ray )
  {
    Vector OA = new Vector( c_origin, ray.getOrigin() );    
    Vector dir = ray.getDirection();
    float dot = OA.dot(dir);
    float delta = dot * dot - OA.getMagnitudeSquare() + 1;
    if ( delta < 0 )
      return false;
    return true;    
  }
  
  public boolean intersects( Ray ray )
  {
    Ray rayLocal = m_transformation.worldToLocal( ray );
    return intersectsCanonical( rayLocal );
  }
  
  /*public IntersectionInfo getIntersectionInfo( Ray ray )
  {
    return null;
  }*/
}


/*class Triangle implements Shape
{
  private Point[3] m_vertices;
  
  Triangle( Point[3] vertices )
  {
    for (int i = 0; i < 3; i++)
    {
      m_vertices[i] = clone(vertices[i]);
    }
  }
  
  public boolean intersects( Ray ray )
  {
  }
  
  public IntersectionInfo getIntersectionInfo( Ray ray )
  {
    return null;
  }
}*/

