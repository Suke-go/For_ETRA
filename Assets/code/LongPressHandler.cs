using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;
using TMPro;

public class LongPressHandler : MonoBehaviour, IPointerDownHandler, IPointerUpHandler, IPointerExitHandler
{
    [Header("Progress Settings")]
    [SerializeField] private float requiredPressTime = 2.0f;
    [SerializeField] private Material progressMaterial;
    
    [Header("Caption Settings")]
    [SerializeField] private GameObject captionPanel;
    [SerializeField] private TextMeshProUGUI captionText;
    [SerializeField] private string caption = "写真の位置情報を確認します。撮影場所や日時などの詳細を表示します。";
    
    [Header("Particle Settings")] 
    [SerializeField] private ParticleSystem particleEffect;
    
    private bool isPressed = false;
    private float pressTime = 0f;
    private bool actionCompleted = false;
    
    private void Start()
    {
        // キャプションパネルは最初は非表示
        if (captionPanel != null)
        {
            captionPanel.SetActive(false);
        }
        
        // パーティクルシステムが存在すれば停止
        if (particleEffect != null)
        {
            particleEffect.Stop();
        }
        
        // プログレスバーをゼロに初期化
        if (progressMaterial != null)
        {
            progressMaterial.SetFloat("_Progress", 0f);
        }
    }
    
    private void Update()
    {
        if (isPressed && !actionCompleted)
        {
            // 長押し時間を更新
            pressTime += Time.deltaTime;
            float progress = Mathf.Clamp01(pressTime / requiredPressTime);
            
            // プログレスバーの更新
            if (progressMaterial != null)
            {
                progressMaterial.SetFloat("_Progress", progress);
            }
            
            // パーティクル効果
            if (particleEffect != null && !particleEffect.isPlaying)
            {
                particleEffect.Play();
            }
            
            // 長押し完了
            if (progress >= 1.0f)
            {
                OnLongPressComplete();
            }
        }
    }
    
    public void OnPointerDown(PointerEventData eventData)
    {
        isPressed = true;
        if (!actionCompleted)
        {
            pressTime = 0f;
        }
    }
    
    public void OnPointerUp(PointerEventData eventData)
    {
        isPressed = false;
        
        // 完了前に離したらリセット
        if (!actionCompleted)
        {
            ResetProgress();
        }
    }
    
    public void OnPointerExit(PointerEventData eventData)
    {
        isPressed = false;
        
        // 完了前に離したらリセット
        if (!actionCompleted)
        {
            ResetProgress();
        }
    }
    
    private void OnLongPressComplete()
    {
        actionCompleted = true;
        
        // パーティクル停止
        if (particleEffect != null)
        {
            particleEffect.Stop();
        }
        
        // キャプション表示
        if (captionPanel != null)
        {
            captionPanel.SetActive(true);
            
            if (captionText != null)
            {
                captionText.text = caption;
            }
        }
    }
    
    public void CloseCaption()
    {
        ResetProgress();
        
        if (captionPanel != null)
        {
            captionPanel.SetActive(false);
        }
    }
    
    private void ResetProgress()
    {
        pressTime = 0f;
        actionCompleted = false;
        
        if (progressMaterial != null)
        {
            progressMaterial.SetFloat("_Progress", 0f);
        }
        
        if (particleEffect != null)
        {
            particleEffect.Stop();
        }
    }
}