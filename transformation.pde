class Transformation
{
  PMatrix m_transformation;
  PMatrix m_inverse;
  
  private void setInverse()
  {
    m_inverse = m_transformation.get();
    m_inverse.invert();
  }
  
  Transformation()
  {
    m_transformation = new PMatrix3D();
    m_transformation.set( 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1 );
    setInverse();
  }
  
  void clone( Transformation other )
  {
    m_transformation.set( other.m_transformation );
    setInverse();
  }
  
  public void translate( Vector v )
  {
    m_transformation.translate( v.X(), v.Y(), v.Z() );
    setInverse();
  }
  
  public void rotate( float angle, Vector v )
  {
    m_transformation.rotate( angle, v.X(), v.Y(), v.Z() );
    setInverse();
  }
  
  public void rotateX( float angle )
  {
    m_transformation.rotateX( angle );
    setInverse();
  }

  public void rotateY( float angle )
  {
    m_transformation.rotateY( angle );
    setInverse();
  }

  public void rotateZ( float angle )
  {
    m_transformation.rotateZ( angle );
    setInverse();
  }
  
  public void scale( float scale )
  {
    m_transformation.scale( scale );
    setInverse();
  }
  
  public void scale( Vector scale )
  {
    m_transformation.scale( scale.X(), scale.Y(), scale.Z() );
    setInverse();
  }

  public void apply( Transformation other )
  {
    m_transformation.apply( other.m_transformation );
    setInverse();
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
    float[] worldArray = { world.x, world.y, world.z, 1 };
    if ( fIsVector )
    {
      worldArray[3] = 0;
    }   
    float[] retVal = new float[4];
    m_inverse.mult( worldArray, retVal );
    return new PVector( retVal[0], retVal[1], retVal[2] );
  }
  
  public Point localToWorld( Point pointLocal )
  {
    PVector local = new PVector( pointLocal.X(), pointLocal.Y(), pointLocal.Z() );
    PVector world = localToWorld( local, false );
    Point worldPoint = new Point( world.x, world.y, world.z );
    return worldPoint;
  }
  
  public Vector localToWorldNormal( Vector normal )
  {
    PVector normalLocal = new PVector( normal.X(), normal.Y(), normal.Z() );
    PMatrix inverse = m_inverse.get();
    inverse.transpose();
    float[] localArray = { normalLocal.x, normalLocal.y, normalLocal.z, 0 };
    float[] values = new float[4];
    m_transformation.mult( localArray, values );
    Vector worlNormal = new Vector( values[0], values[1], values[2] );
    return worlNormal;
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

  public Ray worldToLocal( Ray rayLocal, RayTransformFeedback feedBack )
  {
    Point originPoint = worldToLocal( rayLocal.getOrigin() );
    Vector directionVector = worldToLocal( rayLocal.getDirection() );
    feedBack.setScale( 1/directionVector.getMagnitude() );
    Ray worldRay = new Ray( originPoint, directionVector );
    return worldRay;
  }
}

