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
    m_position.debugPrint();
    m_color.debugPrint();
  }

  public LightedPrimitive intersects( Ray ray, float tMin, float tMax )
  {
    return null;
  }
  
  public IntersectionInfo getIntersectionInfo( Ray ray, float tMin, float tMax )
  {
    return null;
  }
  
  public Color getColor()
  {
    return m_color;
  }
  
  public float getTextureDifferential( Ray r, IntersectionInfo info )
  {
    return -1;
  }
  
  public Ray getRay( Point pointFrom )
  {
    Vector direction = new Vector( pointFrom, m_position );
    direction.normalize();
    Point displacedPoint = new Point( pointFrom, direction, c_epsilon );
    return new Ray( displacedPoint, direction );
  }
}


class DiskLight implements Light
{
  private Point m_center;
  private Vector m_normal;
  private Transformation m_transformation;
  private Color m_color;
  private float m_radius;
  
  DiskLight( Point center, float radius, Vector normal, Color col )
  {
    m_center = center;
    m_radius = radius;
    m_normal = normal;
    m_color = col;
    
    //Evaluate the local to world transform
    Point pointOther = new Point( m_center.X() + m_normal.X(), m_center.Y() + m_normal.Y() + 1.0, m_center.Z() + m_normal.Z() );
    Vector vCenterToOtherPoint = new Vector( m_center, pointOther );
    Vector normalComp = cloneVec( m_normal );
    normalComp.scale( vCenterToOtherPoint.dot( normal ) );
    vCenterToOtherPoint.subtract( normalComp );
    Vector firstAxis = vCenterToOtherPoint;
    firstAxis.normalize();

    Vector secondAxis = firstAxis.cross( normal );
    secondAxis.normalize();
    m_transformation = new Transformation();
    m_transformation.translate( new Vector( c_origin, m_center ) );
    m_transformation.setOrientation( firstAxis, secondAxis, m_normal );
  }

  public LightedPrimitive intersects( Ray ray, float tMin, float tMax )
  {
    return null;
  }
  
  public IntersectionInfo getIntersectionInfo( Ray ray, float tMin, float tMax )
  {
    return null;
  }
  
  public Color getColor()
  {
    return m_color;
  }
  
  private Point sampleSource()
  {
    //Rejection sampling of disk
    Point randomPointLocal;
    while ( true )
    {
      float randX = random(-m_radius, m_radius);
      float randY = random(-m_radius, m_radius);
      randomPointLocal = new Point( randX, randY, 0 );
      if ( randomPointLocal.squaredDistanceFrom( c_origin ) <= m_radius * m_radius )
      {
        break;
      }
    }
    Point world = m_transformation.localToWorld( randomPointLocal );
    return world;
  }
  
  public Ray getRay( Point pointFrom )
  {
    Vector direction = new Vector( pointFrom, sampleSource() );
    Point displacedPoint = new Point( pointFrom, direction, c_epsilon );
    return new Ray( displacedPoint, direction );
  }
}
