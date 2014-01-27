class Transformation
{
  PMatrix m_transformation;
  
  Transformation()
  {
    m_transformation = new PMatrix3D();
  }
  
  public void translate( Point pt )
  {
    m_transformation.translate( pt.X(), pt.Y(), pt.Z() );
  }
  
  public void rotate( float angle, Vector v )
  {
    m_transformation.rotate( angle, v.X(), v.Y(), v.Z() );
  }
  
  public void rotateX( float angle )
  {
    m_transformation.rotateX( angle );
  }

  public void rotateY( float angle )
  {
    m_transformation.rotateY( angle );
  }

  public void rotateZ( float angle )
  {
    m_transformation.rotateZ( angle );
  }
  
  public void scale( float scale )
  {
    m_transformation.scale( scale );
  }  
  
  public Point localToWorld( Point pointLocal )
  {
    PVector local = new PVector( pointLocal.X(), pointLocal.Y(), pointLocal.Z() );
    PVector world = new PVector();
    m_transformation.mult( local, world );
    Point worldPoint = new Point( world.x, world.y, world.z );
    return worldPoint;
  }
  
  public Point worldToLocal( Point pointWorld )
  {
    PVector world = new PVector( pointWorld.X(), pointWorld.Y(), pointWorld.Z() );
    PVector local = new PVector();
    PMatrix inverse = m_transformation.get();
    inverse.invert();
    inverse.mult( world, local );
    Point localPoint = new Point( local.x, local.y, local.z );
    return localPoint;
  }
  
  public Ray worldToLocal( Ray rayLocal )
  {
    Point originPoint = worldToLocal( rayLocal.getOrigin() );
    Point directionPoint = worldToLocal( rayLocal.getDirection() );
    Vector direction = new Vector( directionPoint.X(), directionPoint.Y(), directionPoint.Z() );
    Ray worldRay = new Ray( originPoint, direction );
  }
}
