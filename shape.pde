interface Shape
{
  public Box getBoundingBox();
  public boolean intersects( Ray ray, float tMin, float tMax );
  public ShapeIntersectionInfo getIntersectionInfo( Ray ray, float tMin, float tMax );
}

class Sphere implements Shape
{
  Transformation m_transformation;
  Box m_boundingBox;

  Sphere( float radius, Point center, Transformation transformation )
  {
    m_transformation = new Transformation( transformation );
    m_transformation.translate( new Vector( c_origin, center ) );
    m_transformation.scale( radius );

    m_boundingBox = new Box( new Point(-1, -1, -1), new Point(1, 1, 1), m_transformation );
    m_boundingBox = m_boundingBox.getBoundingBox();
  }

  private boolean intersectsCanonical( Ray ray, float tMin, float tMax )
  {
    Vector OA = new Vector( c_origin, ray.getOrigin() );    
    float scale = 1/ray.getDirection().getMagnitude();
    Vector dirNorm = cloneVec( ray.getDirection() );
    dirNorm.normalize();

    float b = 2*OA.dot(dirNorm);
    float a = 1;
    float c = OA.getMagnitudeSquare() - 1;
    float delta = b*b - 4*a*c;
    if ( delta < 0 )
      return false;

    float sqrtDelta = sqrt( delta );
    float root1 = (-b + sqrtDelta) / 2;
    float root2 = (-b - sqrtDelta) / 2;
    if (root1 < c_epsilon && root2 < c_epsilon)
    {
      return false;
    }

    float minT;
    if ( root1 > c_epsilon && ( root1 < root2 || root2 < 0 ) )
    {
      minT = root1;
    }
    else
    {
      minT = root2;
    }

    float minTScaled = minT * scale;
    if ( minT < 0 || minTScaled < tMin || minTScaled > tMax )
    {
      return false;
    }
    return true;
  }

  private ShapeIntersectionInfo intersectionInfoCanonical( Ray ray, float tMin, float tMax )
  {
    Vector OA = new Vector( c_origin, ray.getOrigin() );
    float scale = 1/ray.getDirection().getMagnitude();
    Vector dirNorm = cloneVec( ray.getDirection() );
    dirNorm.normalize();

    float b = 2*OA.dot(dirNorm);
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
      float root1 = (-b + sqrtDelta) / 2;
      float root2 = (-b - sqrtDelta) / 2;
      if (root1 < c_epsilon && root2 < c_epsilon)
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

      float minTScaled = minT * scale;
      if ( minT < 0 || minTScaled < tMin || minTScaled > tMax )
      {
        return null;
      }

      Point intersectionPointLocal = new Point( ray, minTScaled );
      Vector normalLocal = new Vector( c_origin, intersectionPointLocal );

      //Now go to world space
      Point intersectionPoint = m_transformation.localToWorld( intersectionPointLocal );
      Vector normal = m_transformation.localToWorldNormal( normalLocal );
      return new ShapeIntersectionInfo( intersectionPoint, normal, minTScaled, false );
    }
  }

  public Box getBoundingBox()
  {
    return m_boundingBox;
  }

  public boolean intersects( Ray ray, float tMin, float tMax )
  {
    Ray rayLocal = m_transformation.worldToLocalUnnormalized( ray );
    return intersectsCanonical( rayLocal, tMin, tMax );
  }

  public ShapeIntersectionInfo getIntersectionInfo( Ray ray, float tMin, float tMax )
  {
    Ray rayLocal = m_transformation.worldToLocalUnnormalized( ray );
    return intersectionInfoCanonical( rayLocal, tMin, tMax );
  }
}

/*class NonCanonSphere implements Shape
{
  Box m_boundingBox;

  Sphere( float radius, Point center, Transformation transformation )
  {
    //TODO msati3: Ignoring the transformation for now. Is this correct?
    m_transformation = new Transformation( transformation );
    m_transformation.translate( new Vector( c_origin, center ) );
    m_transformation.scale( radius );

    m_boundingBox = new Box( new Point(-1, -1, -1), new Point(1, 1, 1), m_transformation );
    m_boundingBox = m_boundingBox.getBoundingBox();
  }

  private boolean intersectsCanonical( Ray ray, float tMin, float tMax )
  {
    Vector OA = new Vector( c_origin, ray.getOrigin() );    
    float scale = 1/ray.getDirection().getMagnitude();
    Vector dirNorm = cloneVec( ray.getDirection() );
    dirNorm.normalize();

    float b = 2*OA.dot(dirNorm);
    float a = 1;
    float c = OA.getMagnitudeSquare() - 1;
    float delta = b*b - 4*a*c;
    if ( delta < 0 )
      return false;

    float sqrtDelta = sqrt( delta );
    float root1 = (-b + sqrtDelta) / 2;
    float root2 = (-b - sqrtDelta) / 2;
    if (root1 < c_epsilon && root2 < c_epsilon)
    {
      return false;
    }

    float minT;
    if ( root1 > c_epsilon && ( root1 < root2 || root2 < 0 ) )
    {
      minT = root1;
    }
    else
    {
      minT = root2;
    }

    float minTScaled = minT * scale;
    if ( minT < 0 || minTScaled < tMin || minTScaled > tMax )
    {
      return false;
    }
    return true;
  }

  private ShapeIntersectionInfo intersectionInfoCanonical( Ray ray, float tMin, float tMax )
  {
    Vector OA = new Vector( c_origin, ray.getOrigin() );
    float scale = 1/ray.getDirection().getMagnitude();
    Vector dirNorm = cloneVec( ray.getDirection() );
    dirNorm.normalize();

    float b = 2*OA.dot(dirNorm);
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
      float root1 = (-b + sqrtDelta) / 2;
      float root2 = (-b - sqrtDelta) / 2;
      if (root1 < c_epsilon && root2 < c_epsilon)
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

      float minTScaled = minT * scale;
      if ( minT < 0 || minTScaled < tMin || minTScaled > tMax )
      {
        return null;
      }

      Point intersectionPointLocal = new Point( ray, minTScaled );
      Vector normalLocal = new Vector( c_origin, intersectionPointLocal );

      //Now go to world space
      Point intersectionPoint = m_transformation.localToWorld( intersectionPointLocal );
      Vector normal = m_transformation.localToWorldNormal( normalLocal );
      return new ShapeIntersectionInfo( intersectionPoint, normal, minTScaled, false );
    }
  }

  public Box getBoundingBox()
  {
    return m_boundingBox;
  }

  public boolean intersects( Ray ray, float tMin, float tMax )
  {
    Ray rayLocal = m_transformation.worldToLocalUnnormalized( ray );
    return intersectsCanonical( rayLocal, tMin, tMax );
  }

  public ShapeIntersectionInfo getIntersectionInfo( Ray ray, float tMin, float tMax )
  {
    Ray rayLocal = m_transformation.worldToLocalUnnormalized( ray );
    return intersectionInfoCanonical( rayLocal, tMin, tMax );
  }
}*/

class Triangle implements Shape
{
  Transformation m_transformation;
  Point[] m_vertices;
  Vector m_normal;
  Vector m_e1;
  Vector m_e2;
  Box m_boundingBox;

  Triangle( Point p1, Point p2, Point p3, Transformation transformation )
  {
    m_vertices = new Point[3];
    m_transformation = new Transformation( transformation );
    m_vertices[0] = m_transformation.localToWorld( p1 );
    m_vertices[1] = m_transformation.localToWorld( p2 );
    m_vertices[2] = m_transformation.localToWorld( p3 );

    m_e1 = new Vector( m_vertices[0], m_vertices[1] );
    m_e2 = new Vector( m_vertices[0], m_vertices[2] );

    m_normal = m_e1.cross( m_e2 );
    m_normal.normalize();

    m_boundingBox = new Box( m_vertices ).getBoundingBox();
  }

  public Box getBoundingBox()
  {
    return m_boundingBox;
  }

  //Optimized ray triangle intersection
  private float intersectInternal( Ray ray, float tMin, float tMax )
  {
    Vector p = ray.getDirection().cross( m_e2 );
    Vector tVec, q;
    float det = m_e1.dot( p );
    float u, v, t;
    if ( det > c_epsilon )
    {
      tVec = new Vector( m_vertices[0], ray.getOrigin() );
      u = tVec.dot(p);
      if ( u < 0.0 || u > det )
        return 0;

      q = tVec.cross( m_e1 );
      v = ray.getDirection().dot( q );
      if ( v < 0.0 || v + u > det )
        return 0;
    }
    else if ( det < -c_epsilon )
    {
      tVec = new Vector( m_vertices[0], ray.getOrigin() );
      u = tVec.dot(p);
      if ( u > 0.0 || u < det )
        return 0;

      q = tVec.cross( m_e1 );
      v = ray.getDirection().dot( q );
      if ( v > 0.0 || v + u < det )
        return 0;
    }
    else
    {
      return 0;
    }
    float tIntersection = m_e2.dot( q ) / det;
    if ( tIntersection < c_epsilon || tIntersection < tMin || tIntersection > tMax )
    {
      return 0;
    }
    return tIntersection;
  }

  public boolean intersects( Ray ray, float tMin, float tMax )
  {
    return ( intersectInternal( ray, tMin, tMax ) != 0 );
  }


  public ShapeIntersectionInfo getIntersectionInfo( Ray ray, float tMin, float tMax )
  {  
    float t = intersectInternal( ray, tMin, tMax );
    if ( t != 0 )
    {
      Point inPlane = new Point( ray, t );
      return new ShapeIntersectionInfo( inPlane, m_normal, t, true );
    }
    return null;
  }
}

