using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.SceneManagement;

using UnityEngine.Rendering;

public class PlayerMovement : MonoBehaviour
{
    [SerializeField] float walkSpeed = 1;
    [SerializeField] float jumpForce = 3;

    [SerializeField] float spinTorque = 2;
    [SerializeField] float RayDistance = 2;
    float jumpVelocity;
    bool hasJumped;

    bool hasCapeFeather;
    bool isGrounded;
    Rigidbody rb;
    

    bool hasBalloon;
    void Start()
    {
        hasCapeFeather = false;
        hasBalloon = false;
        if (rb == null){
            rb = GetComponent<Rigidbody>(); 
        }
        isGrounded = false;
    }

    // Update is called once per frame
    void Update()
    {
        float horizontal = Input.GetAxis("Horizontal");
        float vertical = Input.GetAxis("Vertical");

        transform.Translate(Vector3.right * Time.deltaTime * horizontal * walkSpeed); 
        transform.position = new Vector3(transform.position.x, transform.position.y, 0);

        if(isGrounded){
            if(Input.GetKeyDown(KeyCode.Space)){
                rb.AddForce(Vector3.up * jumpForce, ForceMode.VelocityChange);
                jumpVelocity = rb.velocity.y;
                hasJumped = true;
                if(hasBalloon){
                    rb.AddTorque(Vector3.up * spinTorque, ForceMode.Acceleration);
                }

            }
        }
        rb.gameObject.transform.rotation = Quaternion.Euler(Vector3.zero);
    }
    void ReloadCurrentScene(){
        string thisScene = SceneManager.GetActiveScene().name;
        SceneManager.LoadScene(thisScene,LoadSceneMode.Single);
    }

    void OnCollisionEnter(Collision collision) {
        if(collision.collider.tag == "Jumpable Ground" ){
            isGrounded = true;
        }
        if(collision.collider.tag == "end"){
            #if UNITY_EDITOR
            UnityEditor.EditorApplication.isPlaying = false;
            #else
            Application.Quit();
            #endif
        }
        if(collision.collider.tag == "Hazard"){
            ReloadCurrentScene();
        }
        
    }

    void OnCollisionStay(Collision collision) {
        Debug.Log(collision.collider.tag);
        Debug.Log(collision.contacts[0].point.normalized);
        if(collision.collider.tag == "Jumpable Ground"){
            isGrounded = true;
        }
        
    }
    void OnCollisionExit(Collision collision){
         if(collision.collider.tag == "Jumpable Ground" ){
            isGrounded = false;
        }
    }
}
