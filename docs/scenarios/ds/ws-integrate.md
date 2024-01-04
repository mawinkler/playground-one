# Scenario: Integrate Workload Security with Vision One

***DRAFT***

## Prerequisites

- Cloud One Workload Security instance

It is recommended to have some policies and computers already active in your Workload Security instance.

## Current Situation

- Cloud One Workload Security is securing instances.
- Since you want to move to the Vision One platform you start with integrating Workload Security with the platform.

## Integration Workflow

Vision One

1. `Vision One Product Instances --> Add Existing Product`.
2. Choose `Trend Cloud One` --> Click the button to generate the enrollment token. 
3. Copy the enrollment token and save the token.
4. Click `[Save]`.
5. CLick `[Connect and Transfer]`.

Workload Security

6. Login to Workload Security Console.
7. On the Workload Security software console, go to `Administration > System Settings > Trend Micro Vision One (XDR)`.
8. Click `Register enrollment token`.
9. In the dialog that appears, paste the enrollment token and click  `[Register]`.
10. After successful registration, your Workload Security software automatically enables Forward security events to Trend Vision One and changes the Enrollment status to "Registered".

Vision One

11. Go to `Product Instance` App and verify the Workload Security instance being conncted.
12. Optionally install Endpoint Sensor to the instances.

## Result and Benefits

You now have control of the Workload Security instance via Vision One.

🎉 Success 🎉