Shader "Unlit/ColourCorrectionScript"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _LUT("LUT", 2D) = "white" {}
        _Contribution("LUT contribution", Range (0,1)) = 0
        _RedValue ("Red Value offset property", Range(0,1)) = 0.5
        _GreenValue ("Green Value offset property", Range(0,1)) = 0.5
        _BlueValue("Blue value offset property", Range(0,31)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #define COLORS 32.0

            #include "UnityCG.cginc"
            
            

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };
            sampler2D _MainTex;
            sampler2D _LUT;
            float4 _LUT_TexelSize;
            float _Contribution;
            float _RedValue;
            float _GreenValue;
            float _BlueValue;


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float maxColor = COLORS - 1.0;
                fixed4 col = tex2D(_MainTex,i.uv);
                float threshold = maxColor / COLORS;


                float cell = floor(col.b * (maxColor - _BlueValue));
                float offsetX = (cell/COLORS) + (_RedValue / _LUT_TexelSize.z + col.r * threshold/COLORS); 
                float offsetY = _GreenValue /_LUT_TexelSize.w + col.g * threshold/COLORS;

                float2 lutPos = float2(offsetX,offsetY);
                float4 gradedCol = tex2D(_LUT, lutPos);
                return lerp(col,gradedCol , _Contribution);
            }
            ENDCG
        }
    }
}
