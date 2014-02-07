interface Shape
{
  public boolean intersects( Ray ray );
  public ShapeIntersectionInfo getIntersectionInfo( Ray ray );
}

class Sphere implements Shape
{
  Transformation m_transformation;

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
    float b = 2*OA.dot(dir);
    float a = 1;
    float c = OA.getMagnitudeSquare() - 1;
    float delta = b*b - 4*a*c;
    if ( delta < 0 )
      return false;

    float sqrtDelta = sqrt( delta );
    float root1 = (-b + sqrtDelta) / ( 2 * a );
    float root2 = (-b - sqrtDelta) / ( 2 * a );
    if (root1 < c_epsilon && root2 < c_epsilon)
      return false;
    return true;
  }
  
  private ShapeIntersectionInfo intersectionInfoCanonical( Ray ray, float scaleNormal )
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
      float root1 = (-b + sqrtDelta) / ( 2 * a );
      float root2 = (-b - sqrtDelta) / ( 2 * a );
      if (root1 < c_epsilon && root2 < c_epsilon)
      {
        return null;
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

      Point intersectionPointLocal = new Point( ray, minT );
      Vector normalLocal = new Vector( c_origin, intersectionPointLocal );

      //Now go world space
      Point intersectionPoint = m_transformation.localToWorld( intersectionPointLocal );
      Vector normal = m_transformation.localToWorldNormal( normalLocal );
      normal.normalize();
      return new ShapeIntersectionInfo( intersectionPoint, normal, minT * scaleNormal, false );
    }
  }
  
  public boolean intersects( Ray ray )
  {
    RayTransformFeedback feedBack = new RayTransformFeedback();
    Ray rayLocal = m_transformation.worldToLocal( ray, feedBack );
    return intersectsCanonical( rayLocal );
  }
  
  public ShapeIntersectionInfo getIntersectionInfo( Ray ray )
  {
    RayTransformFeedback feedBack = new RayTransformFeedback();
    Ray rayLocal = m_transformation.worldToLocal( ray, feedBack );
    return intersectionInfoCanonical( rayLocal, feedBack.scale() );
  }
}


class Triangle implements Shape
{
  Transformation m_transformation;
  Point[] m_vertices;
  Point[] m_projectedVertices;
  Vector m_normal;

  Triangle( Point p1, Point p2, Point p3, Transformation transformation )
  {
    m_vertices = new Point[3];
    m_projectedVertices = new Point[3];
    m_transformation = new Transformation();
    m_transformation.apply( transformation );
    m_vertices[0] = m_transformation.localToWorld( p1 );
    m_vertices[1] = m_transformation.localToWorld( p2 );
    m_vertices[2] = m_transformation.localToWorld( p3 );
    
    m_projectedVertices[0] = clonePt( m_vertices[0] );
    m_projectedVertices[1] = clonePt( m_vertices[1] );
    m_projectedVertices[2] = clonePt( m_vertices[2] );

    Vector AB = new Vector( m_vertices[0], m_vertices[1] );
    Vector AC = new Vector( m_vertices[0], m_vertices[2] );
    m_normal = AC.cross(AB);
    m_normal.normalize();
    
    if ( abs(m_normal.X()) >= abs(m_normal.Y()) && abs(m_normal.X()) >= abs(m_normal.Z()) )
    {
      m_projectedVertices[0].set( 0, m_projectedVertices[0].Y(), m_projectedVertices[0].Z() );
      m_projectedVertices[1].set( 0, m_projectedVertices[1].Y(), m_projectedVertices[1].Z() );
      m_projectedVertices[2].set( 0, m_projectedVertices[2].Y(), m_projectedVertices[2].Z() );
    }
    else if ( abs(m_normal.Y()) >= abs(m_normal.Z()) )
    {
      m_projectedVertices[0].set( m_projectedVertices[0].X(), 0, m_projectedVertices[0].Z() );
      m_projectedVertices[1].set( m_projectedVertices[1].X(), 0, m_projectedVertices[1].Z() );
      m_projectedVertices[2].set( m_projectedVertices[2].X(), 0, m_projectedVertices[2].Z() );
    }
    else
    {
      m_projectedVertices[0].set( m_projectedVertices[0].X(), m_projectedVertices[0].Y(), 0 );
      m_projectedVertices[1].set( m_projectedVertices[1].X(), m_projectedVertices[1].Y(), 0 );
      m_projectedVertices[2].set( m_projectedVertices[2].X(), m_projectedVertices[2].Y(), 0 );
    }
  }
  
  public boolean intersects( Ray ray )
  {
    float denominator = ray.getDirection().dot( m_normal );
    if ( denominator == 0 )
    {
      return false;
    }

    Vector rayOrigToPlane = new Vector( ray.getOrigin(), m_vertices[0] );
    float t = rayOrigToPlane.dot( m_normal ) / denominator;
    if ( t < c_epsilon )
    {
      return false;
    }
    Point inPlane = new Point( ray, t );

    if ( abs(m_normal.X()) >= abs(m_normal.Y()) && abs(m_normal.X()) >= abs(m_normal.Z()) )
    {
      inPlane.set( 0, inPlane.Y(), inPlane.Z() );
    }
    else if ( abs(m_normal.Y()) >= abs(m_normal.Z()) )
    {
      inPlane.set( inPlane.X(), 0, inPlane.Z() );
    }
    else
    {
      inPlane.set( inPlane.X(), inPlane.Y(), 0 );
    }
    
    Vector AP = new Vector( m_projectedVertices[0], inPlane );
    Vector BP = new Vector( m_projectedVertices[1], inPlane );
    Vector CP = new Vector( m_projectedVertices[2], inPlane );
    Vector AB = new Vector( m_projectedVertices[0], m_projectedVertices[1] );
    Vector BC = new Vector( m_projectedVertices[1], m_projectedVertices[2] );
    Vector CA = new Vector( m_projectedVertices[2], m_projectedVertices[0] );

    Vector v1 = AB.cross( AP );
    Vector v2 = BC.cross( BP );
    Vector v3 = CA.cross( CP );
    
    return ( v1.dot(v2) >= 0 && v1.dot(v3) >= 0 && v2.dot(v3) >= 0 );
  }
  
  
  public ShapeIntersectionInfo getIntersectionInfo( Ray ray )
  {
    float denominator = ray.getDirection().dot( m_normal );
    if ( denominator == 0 )
    {
      return null;
    }

    Vector rayOrigToPlane = new Vector( ray.getOrigin(), m_vertices[0] );
    float t = rayOrigToPlane.dot( m_normal ) / denominator;
    
    if ( t < c_epsilon )
    {
      return null;
    }
    
    Point inPlane = new Point( ray, t );
    return new ShapeIntersectionInfo( inPlane, m_normal, t, true );
  }
}

//Class for bounds checking as well as intersection
class Box implements Shape
{
  private Point m_extent1; //In world coordinates, m_extent1 < m_extent2 in all x,y and z
  private Point m_extent2;
  
  Box( Point point1, Point point2 )
  {
    m_extent1 = point1;
    m_extent2 = point2;
  }
  
  private class BoxIntersectionInfoInternal
  {
    float[] t1 = new float[3];
    float[] t2 = new float[3];
    boolean[] flipped = new boolean[3];
    int largestT1Index;
  }
  
  private BoxIntersectionInfoInternal internalIntersect( Ray ray )
  {
    Point rayOrigin = ray.getOrigin();
    Vector rayDirection = ray.getDirection();
    BoxIntersectionInfoInternal info = new BoxIntersectionInfoInternal();
    info.largestT1Index = -1;

    for (int i = 0; i < 3; i++)
    {
      if ( rayDirection.get(i) != 0 )
      {
        info.t1[i] = (m_extent1.get(i) - rayOrigin.get(i)) / rayDirection.get(i);
        info.t2[i] = (m_extent2.get(i) - rayOrigin.get(i)) / rayDirection.get(i);
      }
    }

    //Flip these indices of t's if they so need to be, so that t1's store the smaller intersection, and t2's the larger
    for (int i = 0; i < 3; i++)
    {
      info.flipped[i] = false;
      if (rayDirection.get(i) < 0)
      {
        float temp = info.t1[i];
        info.t1[i] = info.t2[i];
        info.t2[i] = temp;
        info.flipped[i] = true;
      }
    }

    int largestT1Index = info.t1[0] > info.t1[1] ? ( info.t1[0] > info.t1[2] ? 0:2 ) : ( info.t1[1] > info.t1[2] ? 1:2 );
    float smallestT2 = info.t2[0] < info.t2[1] ? ( info.t2[0] < info.t2[2] ? info.t2[0] : info.t2[2] ) : ( info.t2[1] < info.t1[2] ? info.t2[1] : info.t2[2] );
    if ( info.t1[largestT1Index] <= smallestT2 )
    {
      info.largestT1Index = largestT1Index;
    }
    return info;
  }

  public boolean intersects( Ray ray )
  {
    BoxIntersectionInfoInternal info = internalIntersect(ray);
     if ( info.largestT1Index < 0 || info.t1[info.largestT1Index] < c_epsilon )
     {
       return false;
     }
     return true;
  }
 
  public ShapeIntersectionInfo getIntersectionInfo( Ray ray )
  {
    BoxIntersectionInfoInternal info = internalIntersect(ray);
    if ( info.largestT1Index < 0 || info.t1[info.largestT1Index] < c_epsilon )    
    {
      return null;
    }
    
    int[] normalValues = {0,0,0};
    normalValues[info.largestT1Index] = info.flipped[info.largestT1Index] ? 1 : -1;
    Vector normal = new Vector( normalValues[0], normalValues[1], normalValues[2] );

    Point intersectionPoint = new Point( ray, info.t1[info.largestT1Index] );
    return new ShapeIntersectionInfo( intersectionPoint, normal, info.t1[info.largestT1Index], false );
  }
}

