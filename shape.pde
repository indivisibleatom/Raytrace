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
      return new ShapeIntersectionInfo( intersectionPoint, normal, null, minTScaled, false ); //texture mapping of sphere not supported right now
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

class NonCanonSphere implements Shape
{
  Box m_boundingBox;
  Point m_center;
  float m_radius2;

  NonCanonSphere( float radius, Point center )
  {
    m_radius2 = radius * radius;
    m_center = center;
  
    m_boundingBox = new Box( new Point(m_center.X() - radius, m_center.Y() - radius, m_center.Z() - radius), new Point(m_center.X() + radius, m_center.Y() + radius, m_center.Z() + radius), null );
  }

  public boolean intersects( Ray ray, float tMin, float tMax )
  {
    Vector OA = new Vector( m_center, ray.getOrigin() );

    float b = 2*OA.dot(ray.getDirection());
    float a = 1;
    float c = OA.getMagnitudeSquare() - m_radius2;
    float delta = b*b - 4*a*c;
    if ( delta < 0 )
    {
      return false;
    }

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

    if ( minT < 0 || minT < tMin || minT > tMax )
    {
      return false;
    }
    return true;
  }

  public ShapeIntersectionInfo getIntersectionInfo( Ray ray, float tMin, float tMax )
  {
    Vector OA = new Vector( m_center, ray.getOrigin() );

    float b = 2*OA.dot(ray.getDirection());
    float a = 1;
    float c = OA.getMagnitudeSquare() - m_radius2;
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

      if ( minT < 0 || minT < tMin || minT > tMax )
      {
        return null;
      }

      Point intersectionPoint = new Point( ray, minT );
      Vector normal = new Vector( m_center, intersectionPoint );
      normal.normalize();

      Vector intersectToOrigin = new Vector( intersectionPoint, m_center );
      intersectToOrigin.normalize();
      float u = 0.5 + atan2(intersectToOrigin.Z(), intersectToOrigin.X())/(2*PI);
      float v = 0.5 - asin(intersectToOrigin.Y())/PI;
      return new ShapeIntersectionInfo( intersectionPoint, normal, new Point(u,v,1), minT, false ); //Texture mapping of non canon sphere not supported right now
    }
  }

  public Box getBoundingBox()
  {
    return m_boundingBox;
  }
}

class MovingSphere implements Shape
{
  Box m_boundingBox;
  Point m_center1;
  Point m_center2;
  Vector m_totalMotion;
  float m_radius2;

  MovingSphere( float radius, Point center1, Point center2 )
  {
    m_radius2 = radius * radius;
    m_center1 = center1;
    m_center2 = center2;
    m_totalMotion = new Vector( m_center1, m_center2 );
    
    //TODO msati3: Handle reverse order of specification of centers.
    m_boundingBox = new Box( new Point(m_center1.X() - radius, m_center1.Y() - radius, m_center1.Z() - radius), new Point(m_center2.X() + radius, m_center2.Y() + radius, m_center2.Z() + radius), null );
  }

  public boolean intersects( Ray ray, float tMin, float tMax )
  {
    Point centerCurrent = new Point( m_center1, m_totalMotion, ray.getTime() );
    Vector OA = new Vector( centerCurrent, ray.getOrigin() );   

    float b = 2*OA.dot(ray.getDirection());
    float a = 1;
    float c = OA.getMagnitudeSquare() - m_radius2;
    float delta = b*b - 4*a*c;
    if ( delta < 0 )
    {
      return false;
    }

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

    if ( minT < 0 || minT < tMin || minT > tMax )
    {
      return false;
    }
    return true;
  }

  public ShapeIntersectionInfo getIntersectionInfo( Ray ray, float tMin, float tMax )
  {
    Point centerCurrent = new Point( m_center1, m_totalMotion, ray.getTime() );
    Vector OA = new Vector( centerCurrent, ray.getOrigin() );   

    float b = 2*OA.dot(ray.getDirection());
    float a = 1;
    float c = OA.getMagnitudeSquare() - m_radius2;
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

      if ( minT < 0 || minT < tMin || minT > tMax )
      {
        return null;
      }

      Point intersectionPoint = new Point( ray, minT );
      Vector normal = new Vector( centerCurrent, intersectionPoint );
      normal.normalize();

      return new ShapeIntersectionInfo( intersectionPoint, normal, null, minT, false ); //Texture mapping of moving sphere not supported right now
    }
  }

  public Box getBoundingBox()
  {
    return m_boundingBox;
  }
}

class Triangle implements Shape
{
  Transformation m_transformation;
  Point[] m_vertices;
  Point[] m_textureCoords;
  Vector m_normal;
  Vector m_e1;
  Vector m_e2;
  Box m_boundingBox;

  Triangle( Point p1, Point p2, Point p3, Point texCoords1, Point texCoords2, Point texCoords3, Transformation transformation )
  {
    m_vertices = new Point[3];
    m_transformation = new Transformation( transformation );
    m_vertices[0] = m_transformation.localToWorld( p1 );
    m_vertices[1] = m_transformation.localToWorld( p2 );
    m_vertices[2] = m_transformation.localToWorld( p3 );

    m_textureCoords = null;
    if ( texCoords1 != null )
    {
      m_textureCoords = new Point[3];
      m_textureCoords[0] = texCoords1;
      m_textureCoords[1] = texCoords2;
      m_textureCoords[2] = texCoords3;
    }

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
  
  private float[] getTextureCoordScaled( float u, float v )
  {
    float[] textureCoordinates = new float[2];  
    
    textureCoordinates[0] = (1-u-v)*m_textureCoords[0].X() + u*m_textureCoords[1].X() + v*m_textureCoords[2].X();
    textureCoordinates[1] = (1-u-v)*m_textureCoords[0].Y() + u*m_textureCoords[1].Y() + v*m_textureCoords[2].Y();
    
    print( "Coords " + u + " " + v + " " + textureCoordinates[0] + " " + textureCoordinates[1] + " " );
    return textureCoordinates;
  }
 
  //Optimized ray triangle intersection
  private float intersectInternal( Ray ray, float tMin, float tMax, Point textureCoord )
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
    if ( textureCoord != null )
    {
      u = abs(u);
      v = abs(v);
      float textureCoords[] = getTextureCoordScaled( u, v );
      textureCoord.set( textureCoords[0], textureCoords[1], 1 );
    }
    return tIntersection;
  }

  public boolean intersects( Ray ray, float tMin, float tMax )
  {
    Point textureCoord = null;
    return ( intersectInternal( ray, tMin, tMax, textureCoord ) != 0 );
  }


  public ShapeIntersectionInfo getIntersectionInfo( Ray ray, float tMin, float tMax )
  {
    Point textureCoord = null;
    if (m_textureCoords != null)
    {
      textureCoord = new Point(0,0,0);
    }
    float t = intersectInternal( ray, tMin, tMax, textureCoord );
    if ( t != 0 )
    {
      Point inPlane = new Point( ray, t );
      return new ShapeIntersectionInfo( inPlane, m_normal, textureCoord, t, true );
    }
    return null;
  }
}

