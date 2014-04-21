Color kBlue = new Color(0,0,1);
Color kYellow = new Color(1,1,0);

interface Task extends Runnable
{
}

int MAX_DEPTH = 10; //Max depth of recursive ray-tracing

class RadianceResult
{
  Color radiance;
  float depthValue;
  
  RadianceResult( Color rad, float dValue )
  {
    radiance = rad;
    depthValue = dValue;
  } 
}

class SamplerRenderingTask implements Task
{
  private Scene m_scene;
  private Sampler m_sampler;
  
  SamplerRenderingTask( Scene scene, Sampler sampler, int numTasks, int taskNum )
  {
    m_scene = scene;
    m_sampler = sampler.getSubsampler( numTasks, taskNum );
  }
   
  private RadianceResult computeRadiance( Ray ray, int depth )
  {
    float depthValue = Float.MAX_VALUE; 
    LightManager lightManager = m_scene.getLightManager();
    IntersectionInfo info = m_scene.getIntersectionInfo( ray );
    if ( info == null ) // Can be the case when the t value is negative
    {
      return new RadianceResult( lightManager.getAmbient(), depthValue );
    }
    Material primitiveMaterial = info.primitive().getMaterial();
    Color pixelColor = cloneCol( primitiveMaterial.ambient() );
    Vector normal = info.normal();
    depthValue = info.point().Z();
    
    ray.updateDifferentialsTransfer( info.t(), info.normal() );
    for (int i = 0; i < lightManager.getNumLights(); i++)
    {
      Light light = lightManager.getLight(i);
      Ray shadowRay = light.getRay( info.point() );
      shadowRay.setTime( ray.getTime() );
      
      if ( m_scene.intersects( shadowRay ) == null )
      { 
        Color diffuseColor = null;
        if ( primitiveMaterial.fHasTexture() ) //TODO msati3: Move the checks for texture, etc inside the material
        {
          float[] differentials = new float[2];
          if ( ray.getDelta(0) != null )
          {
            differentials = info.primitive().getTextureDifferentials( ray, info );
          }
          else
          {
            differentials[0] = 0;
            differentials[1] = 0;
          }

          diffuseColor = primitiveMaterial.getTextureColor( info, differentials[0], differentials[1] );
          Vector deltaNormal = primitiveMaterial.getDeltaNormal( info );
          if ( deltaNormal != null )
          {
            normal = cloneVec( info.normal() );
            normal.add( deltaNormal );
            normal.normalize();
          }
        }
        else
        {
          diffuseColor = combineColor( primitiveMaterial.diffuse(), light.getColor() );
        }

        float cosine = normal.dot( shadowRay.getDirection() );
        if ( cosine < 0 ) //Dual sided lighting
        {
          if ( info.fDualSided() )
          {
            cosine = -cosine;
          }
          else
          {
            cosine = 0;
          }
        }

        diffuseColor.scale( cosine );
        
        if ( true )
        {
          float value1 = (1 + cosine)/2;
          float value2 = (1 - value1);
          Color kCool = cloneCol( kBlue );
          Color kWarm = cloneCol( kYellow );
          kCool.scale( value1 );
          kWarm.scale( value2 );
          diffuseColor = kCool;
          diffuseColor.add( kWarm );
        }
  
        Color specularColor = new Color(0,0,0);
        if ( primitiveMaterial.specular() != null )
        {
          Ray viewRay = m_scene.getCamera().getRayToEye( info.point() );
          Vector halfVector = cloneVec( shadowRay.getDirection() );
      5    halfVector.add( viewRay.getDirection() );
          halfVector.normalize();
          specularColor.add( primitiveMaterial.specular() );
          float cosineHalf = pow( info.normal().dot( halfVector ), primitiveMaterial.power() ); ;
          specularColor.scale( cosineHalf );        
          specularColor = combineColor( specularColor, light.getColor() );
        }

        pixelColor.add( diffuseColor );
        pixelColor.add( specularColor );
      }
    }
    Color reflectedRayColor = new Color(0,0,0);
    if ( primitiveMaterial.specular() != null && depth < MAX_DEPTH )
    {
       Ray reflectedRay = ray.reflect( info.normal(), info.point() );
       reflectedRay.setDifferentialsReflection( ray, info );
       reflectedRayColor = cloneCol( computeRadiance( reflectedRay, depth+1 ).radiance );
       reflectedRayColor.scale( primitiveMaterial.reflectConst() );
    }
    pixelColor.add( reflectedRayColor );
    return new RadianceResult( pixelColor, depthValue );
  }
  
  public void run()
  {
    try
    {
      Sample sample = m_sampler.getNextSample();
      do
      {
        Ray ray = m_scene.getCamera().getRay(sample);
        RadianceResult result = computeRadiance(ray, 0);
        Color radiance = result.radiance;
        m_scene.getCamera().getFilm().setRadiance(sample, radiance);
        m_scene.getCamera().getFilm().setDepthValue(sample, result.depthValue);        
        sample = m_sampler.getNextSample();    
      } while ( sample != null );
    }catch(Exception ex)
    {
      if ( DEBUG && DEBUG_MODE >= LOW )
      {
        print("Exception during SamplerRenderingTask::run!!\n");
      }
    }
  }
}
