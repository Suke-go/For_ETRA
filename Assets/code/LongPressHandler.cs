using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;
using TMPro;

// Particle全然ワークしてまへん

public class LongPressHandler : MonoBehaviour, IPointerDownHandler, IPointerUpHandler, IPointerExitHandler
{
    [Header("Progress Settings")]
    [SerializeField] private float requiredPressTime = 2.0f;
    [SerializeField] private Material progressMaterial;
    
    [Header("Caption Settings")]
    [SerializeField] private GameObject captionPanel;
    [SerializeField] private TextMeshProUGUI captionText;
    [SerializeField] private string caption = "Hello World!";
    
    [Header("Particle Settings")] 
    [SerializeField] private ParticleSystem particleEffect;
    
    private bool isPressed = false;
    private float pressTime = 0f;
    private bool actionCompleted = false;
    
    private void Start()
    {
        // false caption
        if (captionPanel != null)
        {
            captionPanel.SetActive(false);
        }
        
        // Stop Particle
        if (particleEffect != null)
        {
            particleEffect.Stop();
        }
        
        // Progressbar reset
        if (progressMaterial != null)
        {
            progressMaterial.SetFloat("_Progress", 0f);
        }
    }
    
    private void Update()
    {
        if (isPressed && !actionCompleted)
        {
            pressTime += Time.deltaTime;
            float progress = Mathf.Clamp01(pressTime / requiredPressTime);
            
            if (progressMaterial != null)
            {
                progressMaterial.SetFloat("_Progress", progress);
            }
            
            if (particleEffect != null && !particleEffect.isPlaying)
            {
                particleEffect.Play();
            }
            
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
        
        // RESET BEFORE COMPLETED
        if (!actionCompleted)
        {
            ResetProgress();
        }
    }
    
    public void OnPointerExit(PointerEventData eventData)
    {
        isPressed = false;
        
        if (!actionCompleted)
        {
            ResetProgress();
        }
    }
    
    private void OnLongPressComplete()
    {
        actionCompleted = true;
        
        if (particleEffect != null)
        {
            particleEffect.Stop();
        }
        
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
