﻿Shader "SeganX/Multi/Metal"
{
    Properties
    {
        _MainTex("Diffuse Texture", 2D) = "white" {}
        _DecalTex("Decal Texture", 2D) = "black" {}
        _MetalTex("Metal Texture", 2D) = "black" {}

        [Enum(ON,1,OFF,0)]	            _ZWrite("Z Write", Int) = 0
        [Enum(BACK,2,FRONT,1,OFF,0)]	_Cull("Cull", Int) = 2

        [Space]
        [Header(Material id 1)]
        _DiffColor1("1: Diffuse Color (alpha x vertex.color)", Color) = (1,1,1,1)
        _DecalColor1("1: Decal Color", Color) = (1,1,1,1)
        _Reflection1("1: Reflection", Range(0, 1)) = 0.5
        [Space]
        _SpecularColor1("1: Specular Color (+ alpha x light.color)", Color) = (1,1,1,1)
        _SpecularAtten1("1: Specular", Range(0, 2)) = 0.5
        _SpecularPower1("1: Specular Power", Range(5, 200)) = 50
        _MetalPower1("1: MetalPower", Range(0, 2)) = 1.5

        [Space]
        [Header(Material id 2)]
        _DiffColor2("2: Diffuse Color (alpha x vertex.color)", Color) = (1,1,1,1)
        _SpecularColor2("2: Specular Color (+ alpha x light.color)", Color) = (1,1,1,1)
        _SpecularAtten2("2: Specular", Range(0, 2)) = 0.5
        _SpecularPower2("2: Specular Power", Range(5, 200)) = 50
        _MetalPower2("2: MetalPower", Range(0, 2)) = 1.5

        [Space]
        [Header(Material id 3)]
        _DiffColor3("3: Diffuse Color (alpha x vertex.color)", Color) = (1,1,1,1)
        _Reflection3("3: Reflection", Range(0, 1)) = 0.5
        [Space]
        _SpecularColor3("3: Specular Color (+ alpha x light.color)", Color) = (1,1,1,1)
        _SpecularAtten3("3: Specular", Range(0, 2)) = 0.5
        _SpecularPower3("3: Specular Power", Range(5, 200)) = 50
        _MetalPower3("3: MetalPower", Range(0, 2)) = 1.5
    }

        SubShader
        {
            Tags
            {
                "RenderType" = "Opaque"
                "LightMode" = "ForwardBase"
            }

            Cull[_Cull]
            ZWrite[_ZWrite]

            Pass
            {
                CGPROGRAM
                #pragma fragmentoption ARB_precision_hint_fastest
                #pragma vertex vert
                #pragma fragment frag
                #pragma multi_compile_fog

                #include "UnityCG.cginc"
                #include "Lighting.cginc"

                struct appdata
                {
                    float4 vrtx : POSITION;
                    float3 norm : NORMAL;
                    float4 colr : COLOR;
                    float2 uv0 : TEXCOORD0;
                    float2 uv1 : TEXCOORD1;
                };

                struct v2f
                {
                    float4 vrtx : SV_POSITION;
                    float3 norm : NORMAL;
                    float4 colr : COLOR;
                    float2 uv0 : TEXCOORD0;
                    float2 uv1 : TEXCOORD1;
                    float2 uv2 : TEXCOORD3;
                    float3 wrl : TEXCOORD2;
                    UNITY_FOG_COORDS(4)
                };

                sampler2D _MainTex;
                float4 _MainTex_ST;
                sampler2D _DecalTex;
                float4 _DecalTex_ST;
                sampler2D _MetalTex;
                float4 _MetalTex_ST;

                v2f vert(appdata v)
                {
                    v2f o;
                    o.vrtx = UnityObjectToClipPos(v.vrtx);
                    o.norm = UnityObjectToWorldNormal(v.norm);
                    o.colr = v.colr;
                    o.uv0 = TRANSFORM_TEX(v.uv0, _MainTex);
                    o.uv1 = TRANSFORM_TEX(v.uv1, _DecalTex);
                    o.uv2 = TRANSFORM_TEX(v.uv1, _MetalTex);
                    o.wrl = mul(unity_ObjectToWorld, v.vrtx).xyz;
                    UNITY_TRANSFER_FOG(o, o.vrtx);
                    return o;
                }


                fixed4 _DecalColor1;
                fixed4 _DiffColor1;
                fixed4 _DiffColor3;
                fixed4 _DiffColor2;
                fixed4 _SpecularColor1;
                fixed4 _SpecularColor3;
                fixed4 _SpecularColor2;
                float _Reflection1;
                float _Reflection3;
                float _SpecularPower1;
                float _SpecularAtten1;
                float _MetalPower1;
                float _SpecularPower3;
                float _SpecularAtten3;
                float _MetalPower3;
                float _SpecularPower2;
                float _SpecularAtten2;
                float _MetalPower2;

                fixed4 frag(v2f i) : SV_Target
                {
                    fixed4 res;

                    uint matId = round(i.colr.r * 255) / 10;
                    if (matId == 1)
                    {
                        res = tex2D(_DecalTex, i.uv1) * _DecalColor1;
                        if (res.a < 1)
                            res.rgb = lerp(tex2D(_MainTex, i.uv0).rgb * _DiffColor1.rgb, res.rgb, res.a);
                        res.rgb *= clamp(i.colr.a + _DiffColor1.a, 0, 1);
                    }
                    else
                    {
                        res.rgb = tex2D(_MainTex, i.uv0).rgb;
                        if (matId == 3)
                            res.rgb *= _DiffColor3.rgb * clamp(i.colr.a + _DiffColor3.a, 0, 1);
                        else
                            res.rgb *= _DiffColor2.rgb * clamp(i.colr.a + _DiffColor2.a, 0, 1);
                    }

                    half3 viewDir = normalize(UnityWorldSpaceViewDir(i.wrl));

                    if (matId == 1)
                    {
                        res.rgb *= 0.7f;
                        if (_Reflection1 > 0.001f)
                        {
                            fixed3 cube = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, reflect(-viewDir, i.norm).rgb).rgb;
                            res.rgb += cube.rgb * _Reflection1;
                        }
                    }
                    else if (matId == 3)
                    {
                        res.rgb *= 0.7f;
                        if (_Reflection3 > 0.001f)
                        {
                            fixed3 cube = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, reflect(-viewDir, i.norm)).rgb;
                            res.rgb += cube.rgb * _Reflection3;
                        }
                    }


                    half3 lightDir = _WorldSpaceLightPos0.xyz;
                    fixed3 diffuse = _LightColor0.rgb * max(0, dot(i.norm, lightDir));
                    fixed3 ambient = (i.norm.y > 0) ? lerp(unity_AmbientEquator.rgb, unity_AmbientSky.rgb, i.norm.y) : lerp(unity_AmbientEquator.rgb, unity_AmbientGround.rgb, -i.norm.y);
                    res.rgb *= saturate(diffuse + ambient);

                    if (matId == 1)
                    {
                        if (_SpecularAtten1 > 0.01f)
                        {
                            float spec = pow(max(0, dot(i.norm, normalize(lightDir + viewDir))), _SpecularPower1) * _SpecularAtten1;
                            res.rgb += (_SpecularColor1.rgb + _LightColor0.rgb * _SpecularColor1.a) * spec;

                            if (_MetalPower1 > 0.01f)
                            {
                                fixed metal = tex2D(_MetalTex, i.uv2).a;
                                res.rgb += spec * metal * _MetalPower1;
                            }
                        }
                    }
                    else if (matId == 3)
                    {
                        if (_SpecularAtten3 > 0.01f)
                        {
                            float spec = pow(max(0, dot(i.norm, normalize(lightDir + viewDir))), _SpecularPower3) * _SpecularAtten3;
                            res.rgb += (_SpecularColor3.rgb + _LightColor0.rgb * _SpecularColor3.a) * spec;

                            if (_MetalPower3 > 0.01f)
                            {
                                fixed metal = tex2D(_MetalTex, i.uv2).a;
                                res.rgb += spec * metal * _MetalPower3;
                            }
                        }
                    }
                    else if (matId == 2)
                    {
                        if (_SpecularAtten2 > 0.01f)
                        {
                            float spec = pow(max(0, dot(i.norm, normalize(lightDir + viewDir))), _SpecularPower2) * _SpecularAtten2;
                            res.rgb += (_SpecularColor2.rgb + _LightColor0.rgb * _SpecularColor2.a) * spec;

                            if (_MetalPower2 > 0.01f)
                            {
                                fixed metal = tex2D(_MetalTex, i.uv2).a;
                                res.rgb += spec * metal * _MetalPower2;
                            }
                        }
                    }

                    res.a = 1;
                    UNITY_APPLY_FOG(i.fogCoord, res);
                    return res;
                }
                ENDCG
            }
        }
            Fallback "Mobile/Diffuse"
}