Color lightRing = new Color( 0.9, 0.7, 0.49 );
Color darkRing = new Color( 0.6, 0.4, 0.3 ); 

interface ProceduralTexture
{
  public Color getColor( IntersectionInfo info );
  public Vector getDNormal( IntersectionInfo info ); //returns the bump-map differential
}

class PerlinProceduralTexture implements ProceduralTexture
{
  private float m_scale; 

  PerlinProceduralTexture( float scale )
  {
    m_scale = scale;
  }

  public Color getColor( IntersectionInfo info )
  {
    Point point = info.point();
    float colorValue = noise_3d( point.X() * m_scale, point.Y() * m_scale, point.Z() * m_scale );
    colorValue += 1;
    colorValue /= 2;
    return new Color( colorValue, colorValue, colorValue );
  }

  public Vector getDNormal( IntersectionInfo info )
  {
    Point point = info.point();
    return dNoise( point.X(), point.Y(), point.Z() );
  }
}

class WoodTexture implements ProceduralTexture
{
  WoodTexture()
  {
  }

  public Color getColor( IntersectionInfo info )
  {
    Point point = info.pointLocal();
    //float radius = info.primitive().getShape().getRadialDistance( point );
    float radiusRing = sqrt( point.Y() * point.Y() + point.Z() * point.Z() );
    float radius = sqrt( point.X() * point.X() + point.Y() * point.Y() + point.Z() * point.Z() );
    radiusRing += (noise_3d( point.X(), point.Y(), point.Z() ) * radius/5);

    float scale = 10.0;
    float highFreqRadiusVariation = noise_3d( point.X(), point.Y() * scale, point.Z() * scale ) / 40.0;
    radiusRing += highFreqRadiusVariation;

    scale = 40.0;
    float highestFreqRadiusVariation = noise_3d( point.X(), point.Y() * scale, point.Z() * scale ) / 80.0;
    radiusRing += highestFreqRadiusVariation;


    scale = 50.0;
    float scaledNoiseX = noise_3d( 0, point.Y() * scale, point.Z() * scale ) / 10.0;
    float scaledNoiseY = noise_3d( point.X() * scale, 0, point.Z() * scale ) / 10.0;
    float scaledNoiseZ = noise_3d( point.X() * scale, point.Y() * scale, 0 ) / 10.0;

    float ringSize = 0.04*radius;
    float divide = radiusRing / ringSize;
    int numRing = (int)divide;
    float tVal = (( numRing + 0.5 ) - divide);
    if ( point.X() >= 0 )
    {
      numRing = 10 + ( 10 - numRing );
    }

    if ( numRing % 2 == 0 )
    {
      return new Color( lightRing.R() + scaledNoiseX, lightRing.G() + scaledNoiseY, lightRing.B() + scaledNoiseZ );
    }
    else
    {
      Color blendedColor = new Color(0, 0, 0);
      blendedColor.blend( darkRing, lightRing, tVal );
      //blendedColor.add( scaledNoiseX, scaledNoiseY, scaledNoiseZ );
      return blendedColor;
    }
  }

  public Vector getDNormal( IntersectionInfo info )
  {
    Point point = info.point();
    return dNoise( point.X(), point.Y(), point.Z() );
  }
}

class MarbleTexture implements ProceduralTexture
{
  MarbleTexture()
  {
  }
  
  float turbulence( IntersectionInfo info )
  {
    float scale = 100;
    Point point = info.pointLocal();
    float retVal = 0;
    while ( scale >= 1 )
    {
      float noise = noise_3d( point.X() * scale, point.Y() * scale, point.Z() * scale ) / scale;
      retVal += noise;
      scale /= 2;
    }
    return retVal;
  }

  public Color getColor( IntersectionInfo info )
  {
    Point point = info.pointLocal();
    float xCoordinate = point.X();

    float sin = 1-sin( 20*(xCoordinate + turbulence( info )) );
    return new Color(sin, sin, sin);
  }

  public Vector getDNormal( IntersectionInfo info )
  {
    return null;
  }
}

class StoneTexture implements ProceduralTexture
{
  private Color[] m_colors;

  StoneTexture()
  {
    m_colors = new Color[5];
    /*m_colors[0] = new Color(0.8, 0.5, 0);
     m_colors[1] = new Color(0.8, 0.5, 0);
     m_colors[2] = new Color(0.8, 0.5, 0);
     m_colors[3] = new Color(0.8, 0.5, 0);
     m_colors[4] = new Color(0.8, 0.5, 0);*/

    m_colors[0] = new Color(0.8, 0.5, 0);
    m_colors[1] = new Color(0.9, 0.2, 0.2);
    m_colors[2] = new Color(0.5, 0.5, 0);
    m_colors[3] = new Color(0.9, 0.6, 0.1);
    m_colors[4] = new Color(0.9, 0.6, 0.1);
  }

  public Color getColor( IntersectionInfo info )
  {
    Point point = info.pointLocal();
    int scale = 3;

    WorleyResult result = gWorleyNoise.valueAt( point, scale );

    if ( result.ID() == 1000021 )
    {
      float colorValue = 0.5;
      float scalePerlin = 100;
      colorValue += ( noise_3d( scalePerlin * point.X(), scalePerlin * point.Y(), scalePerlin * point.Z() ) ) / 4;
      return new Color(colorValue, colorValue, colorValue);
    } 
    else
    {
      int colIndex = (abs(result.ID()) * 53) % 5;
      return cloneCol( m_colors[colIndex] );
    }
  }

  public Vector getDNormal( IntersectionInfo info )
  {
    Point point = info.pointLocal();
    int scale = 3;
    WorleyResult result = gWorleyNoise.valueAt( point, scale );
    return new Vector( abs( result.distance1() - result.distance2() ), abs( result.distance1() - result.distance2() ), abs( result.distance1() - result.distance2() ) );
  }
}

