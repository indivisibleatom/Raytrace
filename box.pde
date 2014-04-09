//Class for bounds checking as well as intersection. Handles axis aligned bounding boxes
class BoxSplitResult
{
  Box box1;
  Box box2;
}

class Box implements Shape
{
  private Point m_extent1; //In world coordinates, m_extent1 < m_extent2 in all x,y and z
  private Point m_extent2;
  Box m_boundingBox;
  Transformation m_transformation;
  float m_surfaceArea;
  
  Box( Point point1, Point point2, Transformation transformation )
  {
    if ( transformation == null ) //If no transformation, treat this as an untransformed box.
    {     
      m_extent1 = point1;
      m_extent2 = point2;
      m_boundingBox = this;
    }
    else
    {
      m_transformation = new Transformation();
      m_transformation.apply(transformation);

      m_extent1 = point1;
      m_extent2 = point2;
      
      float width = point2.X() - point1.X();
      float height = point2.Y() - point1.Y();
      float depth = point2.Z() - point1.Z();      
      
      Point[] extents = new Point[8];
      extents[6] = clonePt(m_extent2);
      extents[7] = clonePt(m_extent1);
      for (int i = 0; i < 6; i++)
      {
        extents[i] = clonePt( m_extent1 );
      }
      extents[0].setZ( m_extent2.Z() );
      extents[1].setZ( m_extent2.Z() ); extents[1].setX( m_extent2.X() );
      extents[2].setX( m_extent2.X() );
      extents[3].setZ( m_extent2.Z() ); extents[3].setY( m_extent2.Y() );
      extents[4].setY( m_extent2.Y() ); extents[4].setX( m_extent2.X() );
      extents[5].setY( m_extent2.Y() );
      
      m_extent1 = transformation.localToWorld( point1 );
      m_extent2 = transformation.localToWorld( point2 );
      for (int i = 0; i < 8; i++)
      {
        extents[i] = transformation.localToWorld( extents[i] );
      }
      fromVertices( extents );
    }
    m_surfaceArea = -1;
  }
  
  private void fromVertices( Point[] vertices )
  {
    int[] minIndex = new int[3]; //An index of min for each coordinate
    int[] maxIndex = new int[3]; //An index of max for each coordinate
 
    //Fill with init values -- perhaps they work out to be good?
    Arrays.fill( minIndex, 0 );
    Arrays.fill( maxIndex, 0 );
 
    for ( int i = 1; i < vertices.length; i++ )
    {
      for (int j = 0; j < 3; j++)
      {
        if ( vertices[i].get(j) < vertices[minIndex[j]].get(j) )
        {
          minIndex[j] = i;
        }
        if ( vertices[i].get(j) > vertices[maxIndex[j]].get(j) )
        {
          maxIndex[j] = i;
        }
      }
    }
    
    m_extent1 = new Point( vertices[minIndex[0]].X(), vertices[minIndex[1]].Y(), vertices[minIndex[2]].Z() );
    m_extent2 = new Point( vertices[maxIndex[0]].X(), vertices[maxIndex[1]].Y(), vertices[maxIndex[2]].Z() );
    m_boundingBox = this;
    m_surfaceArea = -1;
  }
  
  //creates a bounding box from a collection of points
  Box( Point[] vertices )
  {
    fromVertices( vertices );
  }
  
  private void calculateAxisAligned()
  {
    Point[] vertices = new Point[8];
    for (int i = 0; i < vertices.length; i++)
    {
      vertices[i] = new Point(0, 0, 0);
      if ( i < 4 )
      {
        vertices[i].setX( m_extent1.X() );
      }
      else
      {
        vertices[i].setX( m_extent2.X() );
      }
      
      if ( i < 2 || i > 5 )
      {
        vertices[i].setY( m_extent1.Y() );
      }
      else
      {
        vertices[i].setY( m_extent2.Y() );
      }
      
      if ( (i & 1) == 0 )
      {
        vertices[i].setZ( m_extent1.Z() );
      }
      else
      {
        vertices[i].setZ( m_extent2.Z() );
      }
    }
    
    m_boundingBox = new Box( vertices );
  }
  
  private void setSurfaceArea()
  {
    float[] length = new float[3];
    for (int i = 0; i < 3; i++)
    {
      length[i] = (m_extent2.get(i) - m_extent1.get(i));     
      if ( length[i] < 0 )
      {
        print("Negative " + m_extent2.get(i) + " " + m_extent1.get(i) + "\n");
      }
    }
    m_surfaceArea = 2*( length[0]*length[1] + length[1]*length[2] + length[2]*length[0] );
    if ( DEBUG && DEBUG_MODE >= LOW )
    {
      if (m_surfaceArea < 0)
      {
        print("Surface area is negative!!\n");
      }
    }
  }
  
  private class BoxIntersectionInfoInternal
  {
    float[] t1 = new float[3];
    float[] t2 = new float[3];
    int largestT1Index;
  }
  
  //Optimized box ray intersection. Implemented with the aid of paper http://people.csail.mit.edu/amy/papers/box-jgt.pdf. Nifty tricks include +/0 = float.MAX, -/0 = float.MIN
  private BoxIntersectionInfoInternal internalIntersect( Ray ray )
  {
    Point rayOrigin = ray.getOrigin();    
    float[] rayOriginArray = rayOrigin.get();
    float[] boundBoxLowArray = m_boundingBox.m_extent1.get();
    float[] boundBoxHighArray = m_boundingBox.m_extent2.get();
    Vector rayDirection = ray.getDirection();
    BoxIntersectionInfoInternal info = new BoxIntersectionInfoInternal();
    info.largestT1Index = 0;

    float[] div = new float[3];
    for ( int i = 0; i < 3; i++ )
    {
      div[i] = 1/rayDirection.get(i);
    }

    if ( div[0] >= 0 )
    {
      info.t1[0] = (boundBoxLowArray[0] - rayOriginArray[0]) * div[0];
      info.t2[0] = (boundBoxHighArray[0] - rayOriginArray[0]) * div[0];
    }
    else
    {
      info.t1[0] = (boundBoxHighArray[0] - rayOriginArray[0]) * div[0];
      info.t2[0] = (boundBoxLowArray[0] - rayOriginArray[0]) * div[0];
    }
    
    if ( div[1] >= 0 )
    {
      info.t1[1] = (boundBoxLowArray[1] - rayOriginArray[1]) * div[1];
      info.t2[1] = (boundBoxHighArray[1] - rayOriginArray[1]) * div[1];
    }
    else
    {
      info.t1[1] = (boundBoxHighArray[1] - rayOriginArray[1]) * div[1];
      info.t2[1] = (boundBoxLowArray[1] - rayOriginArray[1]) * div[1];
    }
    if ( (info.t1[0] > info.t2[1]) || (info.t1[1] > info.t2[0]) )
    {
      info.largestT1Index = -1;
      return info;
    }
    if ( info.t1[1] > info.t1[0] )
    {
      info.largestT1Index = 1;
      info.t1[0] = info.t1[1];
    }
    if ( info.t2[1] < info.t2[0] )
    {
      info.t2[0] = info.t2[1];
    }
    
    if ( div[2] >= 0 )
    {
      info.t1[2] = (boundBoxLowArray[2] - rayOriginArray[2]) * div[2];
      info.t2[2] = (boundBoxHighArray[2] - rayOriginArray[2]) * div[2];
    }
    else
    {
      info.t1[2] = (boundBoxHighArray[2] - rayOriginArray[2]) * div[2];
      info.t2[2] = (boundBoxLowArray[2] - rayOriginArray[2]) * div[2];
    }
    if ( (info.t1[0] > info.t2[2]) || (info.t1[2] > info.t2[0]) )
    {
      info.largestT1Index = -1;
      return info;
    }
    if ( info.t1[2] > info.t1[0] )
    {
      info.largestT1Index = 2;
      info.t1[0] = info.t1[2];
    }
    if ( info.t2[2] < info.t2[0] )
    {
      info.t2[0] = info.t2[2];
    }

    return info;
  }
  
  public Box getBoundingBox()
  {
    return m_boundingBox;
  }
  
  public void grow( Box other )
  {
    for (int i = 0; i < 3; i++)
    {
      if ( m_extent1.get(i) > other.m_extent1.get(i) )
      {
        m_extent1.set( i, other.m_extent1.get(i) );
      }
      if ( m_extent2.get(i) < other.m_extent2.get(i) )
      {
        m_extent2.set( i, other.m_extent2.get(i) );
      }
    }
  }

  public boolean intersects( Ray ray, float tMin, float tMax )
  {
     BoxIntersectionInfoInternal info = internalIntersect(ray);
     if ( info.largestT1Index < 0 || info.t1[info.largestT1Index] < 0 || info.t1[info.largestT1Index] < tMin || info.t1[info.largestT1Index] > tMax )
     {
       return false;
     }
     return true;
  }
  
  public float[] getIntersectionExtents( Ray ray )
  {
    float[] tExtents = new float[2];
    BoxIntersectionInfoInternal info = internalIntersect(ray);
    tExtents[0] = info.t1[0];
    tExtents[1] = info.t2[0];

    if ( tExtents[0] < 0 && tExtents[1] < 0 )
    {
      return null;
    }
    if ( tExtents[0] < 0 )
    {
      tExtents[0] = 0;
    }
    return tExtents;
  }
  
  public Vector[] getNormalDifferentials( Ray r, IntersectionInfo info )
  {
    return null;
  }
  
  public float[] getTextureDifferentials( Ray r, IntersectionInfo info )
  {
    return null; //TODO msati3: Implement for Box
  }
  
  public ShapeIntersectionInfo getIntersectionInfo( Ray ray, float tMin, float tMax )
  {
    BoxIntersectionInfoInternal info = internalIntersect(ray);
    if ( info.largestT1Index < 0 || info.t1[info.largestT1Index] < 0 || info.t1[info.largestT1Index] < tMin || info.t1[info.largestT1Index] > tMax )
    {
      return null;
    }
    
    int[] normalValues = {0,0,0};
    normalValues[info.largestT1Index] = (ray.getDirection().get(info.largestT1Index) < 0) ? 1 : -1;
    Vector normal = new Vector( normalValues[0], normalValues[1], normalValues[2] );

    Point intersectionPoint = new Point( ray, info.t1[info.largestT1Index] );
    return new ShapeIntersectionInfo( intersectionPoint, normal, null, info.t1[info.largestT1Index], false ); //texture mapping of boxes not supported right now
  }
  
  //Face numbers - 0 -> left x, 2 -> lower y, 4 -> backz
  public float getPlaneForFace( int index )
  {
    int indexFace = index>>1;
    if ( (index & 1) != 0 ) 
    {
      return m_extent2.get(indexFace);
    }
    return m_extent1.get(indexFace);
  }
  
  public float getPlaneOfUpperFaceForDim( int index )
  {
    return m_extent2.get(index);   
  }
  
  public float getPlaneOfLowerFaceForDim( int index )
  {
    return m_extent1.get(index);   
  }

  public float surfaceArea()
  {
    if ( m_surfaceArea == -1 )
    {
      setSurfaceArea();
    }
    return m_surfaceArea;
  }
  
  public BoxSplitResult split( Box boundingBoxOther, int faceIndex )
  {
    BoxSplitResult res = new BoxSplitResult();
    res.box1 = cloneBox( this );
    res.box2 = cloneBox( this );
    
    float value = boundingBoxOther.getPlaneForFace( faceIndex );
    float valueToSet = value;
    if ( value > m_extent2.get(faceIndex>>1) )
    {
      valueToSet = m_extent2.get(faceIndex>>1);
    }
    else if ( valueToSet < m_extent1.get(faceIndex>>1) )
    {
      valueToSet = m_extent1.get(faceIndex>>1);
    }
    res.box1.m_extent2.set(faceIndex>>1, valueToSet );
    res.box2.m_extent1.set(faceIndex>>1, valueToSet );
    res.box1.setSurfaceArea();
    res.box2.setSurfaceArea();
    if ( DEBUG && DEBUG_MODE >= VERBOSE )
    {
      if ( res.box1.surfaceArea() < 0 )
      {
        print("Box.split - negative area!" + boundingBoxOther.getPlaneForFace( faceIndex ));
        this.debugPrint();
        boundingBoxOther.debugPrint();
        res.box1.debugPrint();
        res.box2.debugPrint();
      }
    }
    return res;
  }
  
  public BoxSplitResult split( float proposedPlaneValue, int dimension )
  {
    BoxSplitResult res = new BoxSplitResult();
    res.box1 = cloneBox( this );
    res.box2 = cloneBox( this );
    
    float valueToSet = proposedPlaneValue;
    if ( proposedPlaneValue > m_extent2.get(dimension) )
    {
      valueToSet = m_extent2.get(dimension);
    }
    else if ( valueToSet < m_extent1.get(dimension) )
    {
      valueToSet = m_extent1.get(dimension);
    }
    res.box1.m_extent2.set(dimension, valueToSet );
    res.box2.m_extent1.set(dimension, valueToSet );
    res.box1.setSurfaceArea();
    res.box2.setSurfaceArea();
    if ( DEBUG && DEBUG_MODE >= LOW )
    {
      if ( res.box1.surfaceArea() < 0 )
      {
        print("Box.split - negative area!" + proposedPlaneValue);
        this.debugPrint();
        res.box1.debugPrint();
        res.box2.debugPrint();
      }
    }
    return res;
  }
  
  public Point extent1() { return m_extent1; }
  public Point extent2() { return m_extent2; }
  
  public void debugPrint()
  {
    print("Begin Box :\n");
    m_extent1.debugPrint();
    m_extent2.debugPrint();
    
    float[] length = new float[3];
    for (int i = 0; i < 3; i++)
    {
      length[i] = (m_extent2.get(i) - m_extent1.get(i));     
      print("Length " + i + " " + length[i] + "\n");
    }
    print("Surface area " + m_surfaceArea + "\n");
    print("End Box :\n");
  }
}

Box cloneBox( Box other )
{
  Box newBox = new Box( clonePt( other.extent1() ), clonePt( other.extent2() ), null );
  return newBox;
}

class BoundingBox implements LightedPrimitive
{
  private ArrayList<LightedPrimitive> m_objects;
  private Box m_box;
  //TODO msati3: Move getDiffuse, etc out of lighted primitive and return in the returned structure of intersection info itself
  private LightedPrimitive m_selectedPrimitive;
  
  BoundingBox( ArrayList<LightedPrimitive> objects )
  {
    if (objects.size() > 0)
    {
      m_box = cloneBox(objects.get(0).getBoundingBox());
      m_objects = objects;
      m_selectedPrimitive = null;
      for (int i = 1; i < m_objects.size(); i++)
      {
        m_box.grow(m_objects.get(i).getBoundingBox());
      }
    }
  }
  
  public LightedPrimitive intersects( Ray ray, float tMin, float tMax )
  {
    LightedPrimitive intersectingPrim = null; 
    if ( m_box.intersects( ray, tMin, tMax ) )
     {
       for (int i = 0; i < m_objects.size(); i++)
       {
         intersectingPrim = m_objects.get(i).intersects( ray, tMin, tMax );
         if  ( intersectingPrim != null )
         {
           return intersectingPrim;
         }
       }
     }
     return null;
  }
  
  public IntersectionInfo getIntersectionInfo( Ray ray, float tMin, float tMax )
  {
    IntersectionInfo intersectionInfo = null;
    if ( m_box.getIntersectionInfo( ray, tMin, tMax ) != null )   
    {
       for (int i = 0; i < m_objects.size(); i++)
       {         
         IntersectionInfo currentInfo = m_objects.get(i).getIntersectionInfo( ray, tMin, tMax );
         if ( currentInfo != null && (intersectionInfo == null || currentInfo.t() < intersectionInfo.t()) )
         {
           intersectionInfo = currentInfo;
         }
       }
     }
    return intersectionInfo;
  }

  public Box getBoundingBox() 
  {
    return m_box;
  }

  public Material getMaterial()
  {
    return null;
  }
  
  public Shape getShape()
  {
    return m_box;
  }
  
  public float[] getTextureDifferentials( Ray r, IntersectionInfo info )
  {
    return null;
  }
}


