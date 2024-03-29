Shader "SeganX/UI/Font/Bevel" {
    Properties
    {
        _MainTex("Base (RGB)", 2D) = "white" {}
        _DistanceX("Shadow Distance X:", Float) = 1.5
        _DistanceY("Shadow Distance Y:", Float) = 1.5
        _HighlightColor("Highlight Color:", Color) = (1,1,1,0.3)
        _ShadowColor("Shadow Color:", Color) = (0,0,0,0.3)

        [Enum(ON,1,OFF,0)]	_ZWrite("Z Write", Int) = 0
        [Enum(BACK,2,FRONT,1,OFF,0)]	_Cull("Cull", Int) = 2
        [Enum(Zero,0,One,1,DstColor,2,SrcColor,3,SrcAlpha,5,DstAlpha,7,OneMinusSrcAlpha,10)] _BlendSrc("SrcFactor", Int) = 5
        [Enum(Zero,0,One,1,DstColor,2,SrcColor,3,SrcAlpha,5,DstAlpha,7,OneMinusSrcAlpha,10)] _BlendDest("DstFactor", Int) = 10

        _StencilComp("Stencil Comparison", Float) = 8
        _Stencil("Stencil ID", Float) = 0
        _StencilOp("Stencil Operation", Float) = 0
        _StencilWriteMask("Stencil Write Mask", Float) = 255
        _StencilReadMask("Stencil Read Mask", Float) = 255

        _ColorMask("Color Mask", Float) = 15
    }

        SubShader{

            Tags
            {
                "Queue" = "Transparent"
                "IgnoreProjector" = "True"
                "RenderType" = "Transparent"
                "PreviewType" = "Plane"
            }

            Stencil
            {
                Ref[_Stencil]
                Comp[_StencilComp]
                Pass[_StencilOp]
                ReadMask[_StencilReadMask]
                WriteMask[_StencilWriteMask]
            }

            Cull[_Cull]
            ZWrite[_ZWrite]
            Blend[_BlendSrc][_BlendDest]

            Lighting Off
            ZTest[unity_GUIZTestMode]
            ColorMask[_ColorMask]

            Pass
            {

                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag

                #include "UnityCG.cginc"

                struct vs_in {
                    float4 pos : POSITION;
                    fixed4 col : COLOR;
                    float2 uv0 : TEXCOORD0;
                };

                struct vs_out {
                    float4 pos : SV_POSITION;
                    fixed4 col : COLOR;
                    float2 uv0 : TEXCOORD0;
                };

                sampler2D _MainTex;
                uniform float4 _MainTex_ST;
                fixed _DistanceX;
                fixed _DistanceY;
                fixed4 _ShadowColor;

                vs_out vert(vs_in v)
                {
                    vs_out o;
                    v.pos.xy -= float2(_DistanceX, -_DistanceY);
                    o.pos = UnityObjectToClipPos(v.pos);
                    o.col = v.col * _ShadowColor;
                    o.uv0 = TRANSFORM_TEX(v.uv0, _MainTex);

                    return o;
                }

                fixed4 frag(vs_out i) : SV_Target
                {
                    fixed4 c = tex2D(_MainTex, i.uv0);
                    c.rgb = i.col.rgb;
                    c.a *= i.col.a * i.col.a;
                    return c;
                }
                ENDCG
            }

            Pass
            {
                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag

                #include "UnityCG.cginc"

                struct vs_in {
                    float4 pos : POSITION;
                    fixed4 col : COLOR;
                    float2 uv0 : TEXCOORD0;
                };

                struct vs_out {
                    float4 pos : SV_POSITION;
                    fixed4 col : COLOR;
                    float2 uv0 : TEXCOORD0;
                };

                sampler2D _MainTex;
                uniform float4 _MainTex_ST;
                fixed _DistanceX;
                fixed _DistanceY;
                fixed4 _HighlightColor;

                vs_out vert(vs_in v)
                {
                    vs_out o;
                    v.pos.xy += float2(_DistanceX, -_DistanceY);
                    o.pos = UnityObjectToClipPos(v.pos);
                    o.col = v.col * _HighlightColor;
                    o.col.a = 1 - o.col.a * o.col.a;
                    o.uv0 = TRANSFORM_TEX(v.uv0, _MainTex);
                    return o;
                }

                fixed4 frag(vs_out i) : SV_Target
                {
                    fixed4 c = tex2D(_MainTex, i.uv0);
                    c.rgb = i.col.rgb * c.a;
                    c.a *= i.col.a;
                    return c;
                }
                ENDCG
            }
        }
}
