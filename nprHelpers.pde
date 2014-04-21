float depthThreshHoldDiff = 0.4;
float normalThreshHoldDiff = 0.1;

class NormalMap
{
  private Vector[] m_normal;
  private int m_width;
  private int m_height;
  
  NormalMap( Rect screenDim )
  {
    m_normal = new Vector[screenDim.width() * screenDim.height()];
    m_width = screenDim.width();
    m_height = screenDim.height();
  }
  
  public void setValue( int row, int col, Vector value )
  {
    m_normal[ row * m_width + col ] = value;
  }
  
  public float edgePixelWeight( int row, int col )
  {
    float retVal = 0;
    for (int i = -1; i <= 1; i++)
    {  
      for (int j = -1; j <= 1; j++)
      {
        if ( row+i >= 0 && row+i < m_height && col+j >= 0 && col+j < m_width )
        {
          float deltaNormal = abs(1 - m_normal[row * m_width + col].dot(m_normal[(row+i) * m_width + col + j]));
          if ( deltaNormal > normalThreshHoldDiff )
          {
            retVal += (deltaNormal / normalThreshHoldDiff);
          }
        }
      }
    } 
    return min( retVal, 1 );
  } 
}

class DepthMap
{
  private float[] m_depth;
  private int m_width;
  private int m_height;
  
  DepthMap( Rect screenDim )
  {
    m_depth = new float[screenDim.width() * screenDim.height()];
    m_width = screenDim.width();
    m_height = screenDim.height();
  }
  
  public void setValue( int row, int col, float value )
  {
    m_depth[ row * m_width + col ] = value;
  }
  
  public float edgePixelWeight( int row, int col )
  {
    float retVal = 0;
    for (int i = -1; i <= 1; i++)
    {  
      for (int j = -1; j <= 1; j++)
      {
        if ( row+i >= 0 && row+i < m_height && col+j >= 0 && col+j < m_width )
        {
          float deltaDepth = abs(m_depth[row * m_width + col] - m_depth[(row+i) * m_width + col + j]);
          if ( deltaDepth > depthThreshHoldDiff )
          {
            retVal += ( deltaDepth / depthThreshHoldDiff );
          }
        }
      }
    } 
    return min( retVal, 1 );
  } 
}

class SilhouettePostProcessor
{
  private Film m_f;
  private DepthMap m_d;
  private NormalMap m_n;
   
  SilhouettePostProcessor( Film f, DepthMap d, NormalMap n )
  {
    m_f = f;
    m_d = d;
    m_n = n;
  }
 
 public void postProcess()
 {
    for ( int i = 0; i < m_f.getDim().height(); i++ )
    {
      for ( int j = 0; j < m_f.getDim().width(); j++ )
      {
         float depthEdgeWeight = m_d.edgePixelWeight( i, j );
         float normalEdgeWeight = m_n.edgePixelWeight( i, j );
         float isEdgeWeight = (depthEdgeWeight + normalEdgeWeight)/2; //0 if not an edge, 1 if strong edge
         m_f.modulateColor( i, j, 1 - isEdgeWeight ); 
      }
    }
 } 
}
