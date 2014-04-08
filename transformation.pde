class Transformation
{
  PMatrix m_transformation;
  PMatrix m_inverse;
  PMatrix m_invTranspose;
  boolean m_hasScale = false;
  
  Transformation()
  {
    m_transformation = new PMatrix3D();
    m_inverse = new PMatrix3D();
    m_invTranspose = new PMatrix3D();
    m_hasScale = false;
    m_transformation.set( 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1 );
    m_inverse.set( 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1 );
    m_invTranspose.set( 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1 );
  }
  
  Transformation( Transformation other )
  {
    m_transformation = new PMatrix3D();
    m_inverse = new PMatrix3D();
    m_invTranspose = new PMatrix3D();
    clone(other);
  }
  
  void setOrientation( Vector v1, Vector v2, Vector v3 )
  {
    float[] contents = new float[16];
    m_transformation.get( contents );
    contents[0] = v1.X(); contents[1] = v2.Y(); contents[2] = v3.Z();
    contents[4] = v1.Y(); contents[5] = v2.Y(); contents[6] = v3.Y();
    contents[8] = v1.Z(); contents[9] = v2.Z(); contents[10] = v3.Z();
    m_transformation.set( contents );
    setInverse();
  }
  
  private void setInverse()
  {
    m_inverse = m_transformation.get();
    m_inverse.invert();
    m_invTranspose = m_inverse.get();
    m_invTranspose.transpose();
  }
  
  void clone( Transformation other )
  {
    m_transformation.set( other.m_transformation );
    m_hasScale = other.m_hasScale;
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
    m_hasScale = true;
    setInverse();
  }
  
  public void scale( Vector scale )
  {
    m_transformation.scale( scale.X(), scale.Y(), scale.Z() );
    m_hasScale = true;
    setInverse();
  }

  public void apply( Transformation other )
  {
    m_transformation.apply( other.m_transformation );
    m_hasScale = other.m_hasScale;
    setInverse();
  }
  
  public boolean hasScale()
  {
    return m_hasScale;
  }

  public Point localToWorld( Point pointLocal )
  {
    float[] local = { pointLocal.X(), pointLocal.Y(), pointLocal.Z(), 1 };
    float[] world = new float[4];
    m_transformation.mult( local, world );
    return new Point( world );
  }
  
  public Vector localToWorldNormal( Vector normal )
  {
    float[] localArray = { normal.X(), normal.Y(), normal.Z(), 0 };
    float[] values = new float[4];
    m_invTranspose.mult( localArray, values );
    Vector worldNormal = new Vector( values );
    worldNormal.normalize();
    return worldNormal;
  }

  public Point worldToLocal( Point pointWorld )
  {
    float[] world = { pointWorld.X(), pointWorld.Y(), pointWorld.Z(), 1 };
    float[] local = new float[4];
    m_inverse.mult( world, local );
    return new Point( local );
  }
  
  public Vector worldToLocal( Vector vectorWorld )
  {
    float[] world = { vectorWorld.X(), vectorWorld.Y(), vectorWorld.Z(), 0 };
    float[] local = new float[4];
    m_inverse.mult( world, local );
    return new Vector( local );
  }
  
  public Ray worldToLocal( Ray rayLocal )
  {
    Point originPoint = worldToLocal( rayLocal.getOrigin() );
    Vector directionVector = worldToLocal( rayLocal.getDirection() );
    return new Ray( originPoint, directionVector );
  }
  
  public Ray worldToLocalUnnormalized( Ray rayLocal )
  {
    Point originPoint = worldToLocal( rayLocal.getOrigin() );
    Vector directionVector = worldToLocal( rayLocal.getDirection() );
    return new Ray( originPoint, directionVector, false );
  }
}

