class Transformation
{
  PMatrix m_transformation;
  
  Transformation()
  {
    m_transformation = new PMatrix3D();
    m_transformation.set( 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1 );
  }
  
  public void translate( Vector v )
  {
    m_transformation.translate( v.X(), v.Y(), v.Z() );
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
  
  public void scale( Vector scale )
  {
    m_transformation.scale( scale.X(), scale.Y(), scale.Z() );
  }

  public void apply( Transformation other )
  {
    m_transformation.apply( other.m_transformation );
  } 

  private PVector localToWorld( PVector local, boolean fIsVector )
  {
    float[] localArray = { local.x, local.y, local.z, 1 };
    if ( fIsVector )
    {
      localArray[3] = 0;
    }
    float[] retVal = new float[4];
    m_transformation.mult( localArray, retVal );
    return new PVector( retVal[0], retVal[1], retVal[2] );
  }

  private PVector worldToLocal ( PVector world, boolean fIsVector )
  {
    PMatrix inverse = m_transformation.get();
    inverse.invert();
    float[] worldArray = { world.x, world.y, world.z, 1 };
    if ( fIsVector )
    {
      worldArray[3] = 0;
    }   
    float[] retVal = new float[4];
    inverse.mult( worldArray, retVal );
    return new PVector( retVal[0], retVal[1], retVal[2] );
  }
  
  public Point localToWorld( Point pointLocal )
  {
    PVector local = new PVector( pointLocal.X(), pointLocal.Y(), pointLocal.Z() );
    PVector world = localToWorld( local, false );
    Point worldPoint = new Point( world.x, world.y, world.z );
    return worldPoint;
  }
  
  public Point worldToLocal( Point pointWorld )
  {
    PVector world = new PVector( pointWorld.X(), pointWorld.Y(), pointWorld.Z() );
    PVector local = worldToLocal( world, false );  
    Point localPoint = new Point( local.x, local.y, local.z );
    return localPoint;
  }
  
  public Vector worldToLocal( Vector vectorWorld )
  {
    PVector world = new PVector( vectorWorld.X(), vectorWorld.Y(), vectorWorld.Z() );
    PVector local = worldToLocal( world, true );
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
