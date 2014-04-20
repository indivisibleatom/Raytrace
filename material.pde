class Material
{
  private Color m_ambient;
  private Color m_diffuse;
  private Color m_specular;
  private float m_power;
  private float m_reflect;
  private ImageTexture m_texture;
  private ProceduralTexture m_procTexture;

  Material( Color ambient, Color diffuse )
  {
    this( ambient, diffuse, null, 0, 0 );
  }
  
  Material( Color ambient, Color diffuse, Color shiny, float power, float reflect )
  {
    m_ambient = ambient;
    m_diffuse = diffuse;
    m_specular = shiny;
    m_power = power;
    m_reflect = reflect;
    m_texture = null; 
    m_procTexture = null;
  }
  
  void setTexture( ImageTexture texture )
  {
    m_texture = texture; 
  }
  
  void setProceduralTexture( ProceduralTexture texture )
  {
   m_procTexture = texture;
  }
  
  public Color diffuse() { return m_diffuse; }
  public Color ambient() { return m_ambient; } 
  public Color specular() { return m_specular; }
  public float power() { return m_power; }
  public float reflectConst() { return m_reflect; }
  public boolean fHasTexture() { return (m_texture != null || m_procTexture != null); }
  
  public Color getTextureColor( Point textureCoord )
  {
    PVector lookUpCoord = new PVector( textureCoord.X(), textureCoord.Y(), textureCoord.Z() );
    PVector colorLookUp = m_texture.color_value( lookUpCoord );
    return new Color( colorLookUp.x,colorLookUp.y, colorLookUp.z ); 
  }
  
  public Color getTextureColor( IntersectionInfo info , float footPrintX, float footPrintY )
  {
    if ( m_texture != null )
    {
      Point textureCoord = info.textureCoord();
      PVector lookUpCoord = new PVector( textureCoord.X(), textureCoord.Y(), textureCoord.Z() );
      PVector footPrint = new PVector( footPrintX, footPrintY );
      PVector colorLookUp;
      if ( g_scene.fMipMapEnabled() )
      {
        if ( g_scene.fAnisotropic() )
        {
          colorLookUp = m_texture.color_valueAniso( lookUpCoord,  footPrint );
        }
        else
        {
          lookUpCoord.z = footPrintX < footPrintY ? footPrintX : footPrintY ;
          colorLookUp = m_texture.color_value( lookUpCoord );
        }
      }
      else
      {
        lookUpCoord.z = 0;
        colorLookUp = m_texture.color_value( lookUpCoord );
      }
      return new Color( colorLookUp.x,colorLookUp.y, colorLookUp.z );
    }
    else
    {
      return m_procTexture.getColor( info ); 
    }
  }
  
  public Vector getDeltaNormal( IntersectionInfo info )
  {
    if ( m_procTexture != null )
    {
      return m_procTexture.getDNormal( info );
    }
    return null;
  }
}
