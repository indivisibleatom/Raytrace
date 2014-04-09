interface Task extends Runnable
{
}

int MAX_DEPTH = 10; //Max depth of recursive ray-tracing

class SamplerRenderingTask implements Task
{
  private Scene m_scene;
  private Sampler m_sampler;
  
  SamplerRenderingTask( Scene scene, Sampler sampler, int numTasks, int taskNum )
  {
    m_scene = scene;
    m_sampler = sampler.getSubsampler( numTasks, taskNum );
  }
   
  private Color computeRadiance( Ray ray, int depth )
  {
    LightManager lightManager = m_scene.getLightManager();
    IntersectionInfo info = m_scene.getIntersectionInfo( ray );
    if ( info == null ) // Can be the case when the t value is negative
    {
      return lightManager.getAmbient();
    }
    Material primitiveMaterial = info.primitive().getMaterial();
    Color pixelColor = cloneCol( primitiveMaterial.ambient() );
    
    ray.updateDifferentialsTransfer( info.t(), info.normal() );
    for (int i = 0; i < lightManager.getNumLights(); i++)
    {
      Light light = lightManager.getLight(i);
      Ray shadowRay = light.getRay( info.point() );
      shadowRay.setTime( ray.getTime() );
      
      if ( m_scene.intersects( shadowRay ) == null )
      {
        float cosine = info.normal().dot( shadowRay.getDirection() );
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
  
        Color diffuseColor = null;
        if ( primitiveMaterial.fHasTexture() )
        {
          if ( ray.getDelta(0) != null )
          {
            float[] differentials = info.primitive().getTextureDifferentials( ray, info );
            diffuseColor = primitiveMaterial.getTextureColor( info.textureCoord(), differentials[0], differentials[1] );
          }
          else
          {
            diffuseColor = primitiveMaterial.getTextureColor( info.textureCoord(), 0, 0 );
          }
        }
        else
        {
          diffuseColor = combineColor( primitiveMaterial.diffuse(), light.getColor() );
        }        
        diffuseColor.scale( cosine );
  
        Color specularColor = new Color(0,0,0);
        if ( primitiveMaterial.specular() != null )
        {
          Ray viewRay = m_scene.getCamera().getRayToEye( info.point() );
          Vector halfVector = cloneVec( shadowRay.getDirection() );
          halfVector.add( viewRay.getDirection() );
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
       reflectedRayColor = cloneCol( computeRadiance( reflectedRay, depth+1 ) );
       reflectedRayColor.scale( primitiveMaterial.reflectConst() );
    }
    pixelColor.add( reflectedRayColor );
    return pixelColor;
  }
  
  public void run()
  {
    try
    {
      Sample sample = m_sampler.getNextSample();
      do
      {
        Ray ray = m_scene.getCamera().getRay(sample);
        Color radiance = computeRadiance(ray, 0);
        m_scene.getCamera().getFilm().setRadiance(sample, radiance);
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
