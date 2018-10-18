Shader "Custom/BaseTexture"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
        _MainTex ("Main Tex", 2D) = "white" {}
        _Specular ("Specular", Color) = (1,1,1,1)
        _Gloss("Gloss", Range(8.0, 256)) = 20
    }
    SubShader
    {
        Pass
        {
            Tags{"LightMode"="ForwardBase"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Specular;
            float _Gloss;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                // 将模型的第一组纹理坐标存储到该变量中
                float3 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float2 uv : TEXCOORD2;
            };
            
            v2f vert (a2v v)
            {
                v2f o;

                o.pos = UnityObjectToClipPos(v.vertex);
                // 模型坐标顶点转换世界坐标顶点
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                // 模型坐标法线转换世界坐标法线
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                // 对顶点纹理坐标进行变换，最终得到uv坐标。
                // 方法原理 o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                //_MainTex_ST 是纹理的属性值，写法是固定的为 纹理名+_ST
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                
                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                // 法线方向
                fixed3 worldNormal = normalize(i.worldNormal);
                // 光照方向
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                // 视角方向
                fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                // 对纹理进行采样，返回为计算得到的纹素值，与_Color的乘积作为反射率
                fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
                // 环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                // 漫反射
                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));
                // Blinn模型 计算
                fixed3 halfDir = normalize(worldViewDir + worldLightDir);
                // 高光反射
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);
                // 相加后输出颜色
                return fixed4(ambient + diffuse + specular, 1);
            }
            ENDCG
        }
    }
}
