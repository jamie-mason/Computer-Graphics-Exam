Shader "Unlit/Hollogram"
{
    Properties
    {
        _RimColour("Hollogram Colour", Color) = (1,1,1,1)
        _RimTexture("Hollogram Texture", 2D) = "white" {}
        _RimPower("Hollogram Power", Float) = 1
        _ToggleRimPower("Toggle Hollogram", Range(0,1)) = 1
        
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent"}

        Pass{
            ColorMask 0
            ZWrite On
        }
        Pass
        {
            
            //Blend SrcAlpha one
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float3 viewDir : TEXCOORD1;
                float3 normal : NORMAL;
                float4 vertex : SV_POSITION;
            };

            sampler2D _RimTexture;
            float _ToggleRimPower;
            float _RimPower;
            float4 _RimColour;
            v2f vert (appdata v)
            {
                v2f o;  //initialize the output struct object reference.
                o.vertex = UnityObjectToClipPos(v.vertex); //get the vertex transforms in clipping space
                float3 cameraPos = _WorldSpaceCameraPos.xyz; // Get camera position
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz; // Transform vertex to world space
                o.viewDir = normalize(cameraPos - worldPos); // Calculate view direction
                o.normal = normalize(mul(v.normal, (float3x3)unity_WorldToObject)); //get the normals in world space
                o.uv = v.uv;  //set the output uvs to the input uvs.
                
                return o;  //return the output struct object.
            }

            float4 frag (v2f i) : SV_Target  
            {
                float4 rimTex = tex2D(_RimTexture, i.uv); //sample the rim texture if any.
                float rim = saturate(dot(i.viewDir, i.normal));  //saturate the rim factor to the angle between the view direction and the object normals
                rim = pow(rim,_RimPower);   //set the rim power to the inverse of the saturated rim factor to the power of the rim power.
                if(_ToggleRimPower<0.5){  //if rimpower is less than 5 turn it off.
                    rim = 0;
                }
                float4 col = rimTex * _RimColour * rim;  //set col variable to the colour product of the hollogram texture colour, rim colour and the rim factor.
                return col; //return the colour product as the fragment shader output.
            }
            ENDCG 
        }
    }
    FallBack "Diffuse"
}
