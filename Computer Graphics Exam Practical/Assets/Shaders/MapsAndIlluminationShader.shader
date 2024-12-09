Shader "Unlit/MapsAndIlluminationShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _BumpMap ("Normal Map", 2D) = "bump" {}
        _BumpScale ("Bump Scale", Range(0,1)) = 0.5
        _RoughnessMap ("Roughness Map (G)", 2D) = "white" {}
        _HeightMap ("Height Map", 2D) = "white" {}
        _HeightScale ("Height Scale", Range(0, 0.1)) = 0.02
        _Glossiness ("Glossiness", Range(0,1)) = 0.5
        _SpecColor("Specular Color", Color) = (1, 1, 1, 1) // Specular color
        _Shininess("Shininess", Range(1, 100)) = 10 // Shininess factor for specular highlights

        _TwoSided ("Enable Two-Sided Rendering", Range(-1,1)) = 0
        _ToggleTextures ("Toggle Texture", Range(0,1)) = 1
        _ToggleIllumination ("Toggle Illumination", Range(0,1)) = 1
        _RimColor ("Rim Light Color", Color) = (1, 1, 1, 1)
        _RimPower ("Rim Light Power", Range(0, 10)) = 3.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Cull [_TwoSided]

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
  

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 normal : TEXCOORD1;
                float3 lightDir : TEXCOORD2;
                float3 viewDir : TEXCOORD3;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            sampler2D _BumpMap;
            sampler2D _RoughnessMap;
            sampler2D _HeightMap;

            float4 _Color;
            float4 _SpecColor;
            float4 _LightColor0;
            float _Shininess;
            half _Glossiness;
            float _BumpScale;
            float _HeightScale;
            float _ToggleTextures;
            float _ToggleIllumination;
            float4 _RimColor;
            float _RimPower;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.normal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
                bool isDirectional = (_WorldSpaceLightPos0.w == 0.0);

                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                float4 lightPos = _WorldSpaceLightPos0;
                if(!isDirectional){
                    o.lightDir = normalize(lightPos.xyz - worldPos.xyz);
                }
                else{
                    o.lightDir = normalize(lightPos.xyz);

                }

                float3 cameraPos = _WorldSpaceCameraPos;

                o.viewDir = normalize(cameraPos.xyz - worldPos.xyz);

                return o;
            }

            float2 ParallaxOffset(float2 uv, float height, float3 viewDir)
            {
                float depth = height * _HeightScale;
                float3 viewTangent = normalize(viewDir);
                float parallax = depth * -viewTangent.z; // Only adjust along view direction
                return uv + parallax * viewTangent.xy;
            }

            float4 frag (v2f i) : SV_Target
            {
                float height = tex2D(_HeightMap, i.uv).r;
                float2 parallaxUV = (0,0);
                float4 finalColor = (1,1,1,1) * 0;
                float roughness = 0;
                float2 normalMap = (0,0);
                float rim = 0; 


                if(_ToggleTextures >= 0.5)
                {
                    finalColor = tex2D(_MainTex, i.uv); // Sample texture
                    parallaxUV = ParallaxOffset(i.uv, height ,i.viewDir);
                    roughness = tex2D(_RoughnessMap, i.uv).g;
                    normalMap = tex2D(_BumpMap, parallaxUV) * _BumpScale;
                }
                rim = 1.0 - saturate(dot(i.normal, i.viewDir));
                rim = pow(rim, _RimPower); // Control the intensity of the rim light
                
                

                // Calculate Roughness and Normal
                float smoothness = 1.0 - roughness;
                float3 normal = normalize(i.normal + float3(normalMap, 0.0));

                // Diffuse lighting

                float diff = max(0.0,dot(normal, i.lightDir));

                // Specular lighting
                float3 reflectDir = reflect(-i.lightDir, normal);
                float specFactor = pow(max(dot(normal, reflectDir), 0.0), smoothness * _Shininess);
                float4 specColour = specFactor * _SpecColor * _LightColor0;

                

                // Ambient lighting
                float4 ambientLight = _Color * UNITY_LIGHTMODEL_AMBIENT;

                // Diffuse color
                if(_ToggleIllumination >= 0.5){
                    float4 diffuseColour =  _Color *_LightColor0 * diff;
                    finalColor += ambientLight;
                    finalColor *= diffuseColour;
                    finalColor.rgb += rim * _RimColor.rgb;
                    finalColor.rgb += specColour.rgb;
                }
                


                // Rim lighting effect
                

                return finalColor;
            }
            ENDCG
        }
    }
}
