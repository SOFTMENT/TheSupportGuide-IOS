      const admin = require("firebase-admin");
      const functions = require("firebase-functions");

            /* eslint-disable max-len */
      admin.initializeApp({
        credential: admin.credential.cert({
          type: "service_account",
          project_id: "the-support-guide",
          private_key_id: "4223c28657e1f1383b3a26578ae95ab2795999d8",
          private_key: "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQDQ4FzamsjT3/kB\nkv79c+HYLrkUtZpO4KE0Q3PVKcdckaBXtfYUBtV6KnAHqDkgx1QQhGzmt1tTSJTO\nunEegSjboqI76tv93BFo02sZu9Pf/W0jG/OeYTM0FqQeX7BrYXUM3cVLFxlGqwXe\ndS9oV7NuREWloAWz8BsJdNCT/NO44MmMnxK4fI5XErOndpkx09faaruMGfTKPsf9\n1SSv4GXnOgp+t25HYn9k56IYIJMzsylsMPeB8VZ7Ps1Sp3jPAiN4pvDUx52tb+3d\nFGC+PxDPNkvyhmAuyMQ19LVdr90tLDSj51TxXKiRvBfenmWU9BG4MMdWpREukbOI\n2m1AP1eLAgMBAAECggEAHiGfg3F8swPGOfHokstaswLadCBWaDaDSrTISuHB/pqL\nVNvM6cqqlPr2OkSMKSxX9iIES6v7oqH/xWqj0tCzAiwN1zLkFVTftg15j7bGs7Mt\nQTlRBXHkHwl9F1yaaIMgjYCYa2KjpMwbBqJE+npcSfXTTjctW22xmMWfKRn5uNuB\ntzFpxKGJxtwzJoqo35GDvqqnf5H9ec/mQohXODk9/sugWIJaRBkmyPGxxXfKLaOT\nFNvU5zdZ+Tx3G2hvqo5hMtfwb+we76mjwyORPgu3hVnnjWfPz+Mmzgn71yz+rKDZ\n2/Cydq2i0L8z5Gdj5JB1aqbwteQb4bBsrsSLVnqDQQKBgQDu7qZQlBWS4ZSHs2T0\nNQOxWg+DAh5uAfif2cvhH6Ttwumbb/jXhIlMePeZqg1mLoasuuTMr37swNFOhkdY\ndbyrUavPLnXYfCWY4yvwWUhS6ULpBzpTVQDPC7yoDuyIr7ZdAa4rtid6qn3jR5b/\n583bH1LS/uZILHWe90ypZQO+uwKBgQDfzBU4Cmz7jnW5EP5vQfYGU8Y7Bi2lw/Va\nR0avRC7z/3GMByTDGn18vCh/0ItOO+EG47FkoiHLku92diuCx3rENa5NW60OQZN1\nnJ0Yq6q3lk0neTSfFSpJudJnEYsCxwSx+SFSMNxuA8iBSXD+x4Oicp9dw4yyNrAU\nzpwPRPOFcQKBgAn9SE7OIijF7aPOyEW9ga4Eiel8STFoO7DTNkbvP8IBCCtLfyfj\njqn31MJD7dN71n2aQr6cB752QUn7Kzhzk7PF8lzzIFIwvpGpzch6sx9kSTvc5X9e\nam49m2GbXiBI2GMDEvkY4IWsYx8BezqvwleK87eGmLIjybcft8DNTF7JAoGAUdRS\nceJGBRkK7HdNQSsSJTAejFhu+myTWsYzD0TUEj11rCi0hW47Mg+uk0WSmjGEzzsU\nEuLBjqkUS/FbaX884V9rczexKERMAbYZLvsd+fDIF0XXOs/HXZvHVg5xELvqeJTK\nXT4ma0eQ2c0btt0GwbA9m1A0MrmSWplNMLwaetECgYBR/pgNofaz1P26XtVVzTnk\n2vCPpNPFpdT7Y7lb2B+Ki9YD8klzMdT1uARzFa/qcRAx56AwCGfm8wTgEc1WOc4k\nfuAr0xuO5CgEP826VwxW4NB4yvefPxInofM1827de4FTI87laNUqgT6f5gACQtOj\nAAt+mi5dXliZ56JgbCWU3g==\n-----END PRIVATE KEY-----\n",
          client_email: "firebase-adminsdk-47nob@the-support-guide.iam.gserviceaccount.com",
          client_id: "117400138524709547835",
          auth_uri: "https://accounts.google.com/o/oauth2/auth",
          token_uri: "https://oauth2.googleapis.com/token",
          auth_provider_x509_cert_url: "https://www.googleapis.com/oauth2/v1/certs",
          client_x509_cert_url: "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-47nob%40the-support-guide.iam.gserviceaccount.com",
        }),
      });
            /* eslint-enable max-len */

      admin.auth().setCustomUserClaims("nrYBJuFnxfMO2Mv5aRJUWllwuTb2",
        {admin: true})
      .then(() => {
        console.log("WOW I AM ADMIN");
      });


      exports.createUser = functions
      .runWith({
        timeoutSeconds: 540,
        memory: "2GB",
      })
      .https.onCall(async (data, context)=>{
        if (!(context.auth && context.auth.token && context.auth.token.admin)) {
          return {"response": "failed", "value": "permission denied"};
        }
        try {
          const user = await admin.auth().createUser({
            disabled: false,
            displayName: data.name,
            email: data.email,
            password: data.password,

          });

          if (data.isAdmin) {
          admin.auth().setCustomUserClaims(user.uid,
            {admin: true})
          .then(() => {
            console.log("WOW I AM SUB-ADMIN");
          });
        }
          return {"response": "success", "value": user.uid};
        } catch (error) {
          return {"response": "failed", "value": error.message};
        }
      });

      exports.updateUser = functions
      .runWith({
        timeoutSeconds: 540,
        memory: "2GB",
      })
      .https.onCall(async (data, context)=>{
        if (!(context.auth && context.auth.token && context.auth.token.admin)) {
          return {"response": "failed", "value": "permission denied"};
        }
        try {
          const user = await admin.auth().updateUser(data.uid, {
            disabled: false,
            displayName: data.name,
            email: data.email,
            password: data.password,

        });        
         
         return {"response": "success", "value": user.uid};
        } catch (error) {
          return {"response": "failed", "value": error.message};
        }
      });



   exports.deleteUser = functions
      .runWith({
        timeoutSeconds: 540,
        memory: "2GB",
      })
      .https.onCall(async (data, context)=>{
        if (!(context.auth && context.auth.token && context.auth.token.admin)) {
          return {"response": "failed", "value": "permission denied"};
        }
        return admin.auth().deleteUser(data.uid);
      });
