interface Shape
{
  public boolean intersects( Ray ray );
  public ShapeIntersectionInfo getIntersectionInfo( Ray ray );
}

class Sphere implements Shape
{
  Transformation m_transformation;
  Point m_center;
  float m_radius;

  Sphere( float radius, Point center, Transformation transformation )
  {
    m_transformation = new Transformation();
    m_transformation.apply( transformation );
    m_transformation.translate( new Vector( c_origin, center ) );
    m_transformation.scale( radius );
    m_radius = radius;
    m_center = center;
  }
  
  private boolean intersectsCanonical( Ray ray )
  {
    Vector OA = new Vector( c_origin, ray.getOrigin() );    
    Vector dir = ray.getDirection();
    float b = 2*OA.dot(dir);
    float a = 1;
    float c = OA.getMagnitudeSquare() - 1;
    float delta = b*b - 4*a*c;
    if ( delta < 0 )
      return false;

    float sqrtDelta = sqrt( delta );
    float root1 = -b + sqrtDelta / ( 2 * a );
    float root2 = -b - sqrtDelta / ( 2 * a );
    if (root1 < 0 && root2 < 0)
      return false;
    return true;    
  }
  
  private ShapeIntersectionInfo intersectionInfoCanonical( Ray ray )
  {
    Vector OA = new Vector( c_origin, ray.getOrigin() );    
    Vector dir = ray.getDirection();
    float b = 2*OA.dot(dir);
    float a = 1;
    float c = OA.getMagnitudeSquare() - 1;
    float delta = b*b - 4*a*c;
    if ( delta < 0 )
    {
      return null;
    }
    else
    {
      float sqrtDelta = sqrt( delta );
      float root1 = -b + sqrtDelta / ( 2 * a );
      float root2 = -b - sqrtDelta / ( 2 * a );
      if (root1 < 0 && root2 < 0)
      {
        return null;
      }
      float minT;
      if ( root1 > 0 && ( root1 < root2 || root2 < 0 ) )
      {
        minT = root1;
      }
      else
      {
        minT = root2;
      } 
      Point intersectionPoint = new Point( ray, minT );
      Vector normal = new Vector( m_center, intersectionPoint );
      normal.normalize();
      return new ShapeIntersectionInfo( intersectionPoint, normal, minT );
    }
  }
  
  public boolean intersects( Ray ray )
  {
    Ray rayLocal = m_transformation.worldToLocal( ray );
    return intersectsCanonical( rayLocal );
  }
  
  public ShapeIntersectionInfo getIntersectionInfo( Ray ray )
  {
    Ray rayLocal = m_transformation.worldToLocal( ray );
    return intersectionInfoCanonical( rayLocal );
  }
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

