float depthThreshHoldDiff = 0.4;

class NormalMap
{
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
  
  private boolean isEdgePixel( int row, int col )
  {
    for (int i = -1; i <= 1; i++)
    {  
      for (int j = -1; j <= 1; j++)
      {
        if ( row+i >= 0 && row+i < m_height && col+j >= 0 && col+j < m_width )
        {
          if ( abs(m_depth[row * m_width + col] - m_depth[(row+i) * m_width + col + j]) > depthThreshHoldDiff )
          {
            return true;
          }
        }
      }
    } 
    return false;
  } 
  
  private void processForSilhouettes( Film f )
  {
    for ( int i = 0; i < m_height; i++ )
    {
      for ( int j = 0; j < m_width; j++ )
      {
        if ( isEdgePixel( i, j ) )
        {
          f.modulateColor( i, j, 0 );
        }        
      }
    }
  }
  
  public void postProcess( Film f )
  {
    processForSilhouettes( f );
  }
}
