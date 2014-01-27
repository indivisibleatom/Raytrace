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

  private PVector localToWorld( PVector local )
  {
    PVector world = new PVector();
    m_transformation.mult( local, world );
    return world;
  }

  private PVector worldToLocal ( PVector world )
  {
    PVector local = new PVector();
    PMatrix inverse = m_transformation.get();
    inverse.invert();
    inverse.mult( world, local );
    return local;
  }
  
  public Point localToWorld( Point pointLocal )
  {
    PVector local = new PVector( pointLocal.X(), pointLocal.Y(), pointLocal.Z() );
    PVector world = localToWorld( local );
    Point worldPoint = new Point( world.x, world.y, world.z );
    return worldPoint;
  }
  
  public Point worldToLocal( Point pointWorld )
  {
    PVector world = new PVector( pointWorld.X(), pointWorld.Y(), pointWorld.Z() );
    PVector local = worldToLocal( world );  
    Point localPoint = new Point( local.x, local.y, local.z );
    return localPoint;
  }
  
  public Vector worldToLocal( Vector vectorWorld )
  {
    PVector world = new PVector( vectorWorld.X(), vectorWorld.Y(), vectorWorld.Z() );
    PVector local = worldToLocal( world );
    Vector localVector = new Vector( local.x, local.y, local.z );
    return localVector;
  }

  public Ray worldToLocal( Ray rayLocal )
  {
    Point originPoint = worldToLocal( rayLocal.getOrigin() );
    Vector directionVector = worldToLocal( rayLocal.getDirection() );
    Ray worldRay = new Ray( originPoint, directionVector );
    return worldRay;
  }
}
