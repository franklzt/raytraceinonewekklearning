//漫反射+高光反射+凹凸纹理+遮罩
Shader "Custom/MaskTexture"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Main Tex", 2D) = "white" {}
		_BumpTex("Bump Tex", 2D) = "Bump" {}
		_BumpScale("Bump Scale", Float) = 1
		_SpecularMask("Specular Mask Tex", 2D) = "white" {}
		_SpecularScale("Specular Scale", Float) = 1
		_Specular("Specular", Color) = (1,1,1,1)
		_Gloss("Gloss", Range(8.0, 256)) = 20
	}
		SubShader
		{
			Pass
			{
				Tags{"LightMode" = "ForwardBase"}

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#include "UnityCG.cginc"
				#include "Lighting.cginc"

				fixed4 _Color;
				sampler2D _MainTex;
				float4 _MainTex_ST;
				sampler2D _BumpTex;
				float4 _BumpTex_ST;
				float _BumpScale;
				sampler2D _SpecularMask;
				float4 _SpecularMask_ST;
				float _SpecularScale;
				fixed4 _Specular;
				float _Gloss;

				struct a2v
				{
					float4 vertex : POSITION;
					// 将模型的法线方向存储到变量中
					float3 normal : NORMAL;
					// 将模型的第一组纹理坐标存储到变量中
					float3 texcoord : TEXCOORD0;
					// 将模型的顶点切线方向存储到变量中，float4的原因是用w来决定切线空间的第三个坐标轴——福切线的方向性。
					float4 tangent : TANGENT;
				};

				struct v2f
				{
					float4 pos : SV_POSITION;
					float2 uv : TEXCOORD0;
					float3 lightDir : TEXCOORD1;
					float3 viewDir : TEXCOORD2;
				};

				v2f vert(a2v v)
				{
					v2f o;

					o.pos = UnityObjectToClipPos(v.vertex);

					o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);

					TANGENT_SPACE_ROTATION;

					o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex));
					o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex));

					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{
					// 世界空间的光照方向
					fixed3 tangentLightDir = normalize(i.lightDir);
				// 世界空间的视角方向
				fixed3 tangentViewDir = normalize(i.viewDir);

				// 对法线纹理进行采样
				fixed4 packedNormal = tex2D(_BumpTex, i.uv);
				fixed3 tangentNormal = UnpackNormal(packedNormal);
				tangentNormal.xy *= _BumpScale;
				tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

				// 对纹理进行采样，返回为计算得到的纹素值，与_Color的乘积作为反射率
				fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
				// 环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				// 漫反射
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangentNormal, tangentLightDir));
				// Blinn模型 计算
				fixed3 halfDir = normalize(tangentViewDir + tangentLightDir);
				// 对高光反射的r通道计算掩码值
				fixed specularMask = tex2D(_SpecularMask, i.uv).r * _SpecularScale;
				// 高光反射 添加遮罩
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(tangentNormal, halfDir)), _Gloss) * specularMask;
				// 相加后输出颜色
				return fixed4(ambient + diffuse + specular, 1);
			}
			ENDCG
		}
		}
}