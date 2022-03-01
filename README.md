# VOLCANO 
Previously named -  SmartScan
This repositoray presents datasets and empirical analysis results that use code clone detection techniques for identifying vulnerabilities and their variations in smart contracts. Our empirical analysis is conducted using Nicad code clone detection tool on an Evaluation Dataset of approximately 50k Ethereum smart contracts.  

This repository contains: 
  * Evaluation Dataset - approximately 50k smart contracts extracted from the Ethereum network
  * Vulnerability Dataset - Ethereum smart contracts with confirmed vulnerabilities of following 8 types:
   - Reentrancy 
   - Denial of Service 
   - Call-to-Unknown 
   - Mishandled Exceptions
   - Gasless Send
   - Typecasting Errors
   - Weak Access Modifiers 
   - Integer Underflow/Overflow
* Results of VOLCANO - empirical analysis of cross code clone detection between the Vulnerability Dataset and Evaluation Dataset. 
