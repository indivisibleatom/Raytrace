class LightManager
{
  private ArrayList<Light> m_lights;
  private Color m_ambientLight;
  
  public Color getAmbient() { return m_ambientLight; }
  public int getNumLights() { return m_lights.size(); }
  public Light getLight( int i ) { return m_lights.get( i ); }
}
