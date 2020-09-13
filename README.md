# Bacol

[![Open Source Love](https://badges.frapsoft.com/os/v1/open-source.svg?v=102)](https://opensource.org/licenses/MIT)

Show some :heart: and star :star: the repo to support the project or [Tweet](https://twitter.com/intent/tweet?text=Wow:&url=https%3A%2F%2Fgithub.com%2Famitkma%2FBacol) about it.

## What is Bacol:question:
Build Apk from Command-Line (aka. Bacol) is a bash script based micro build tool which can be used to compile basic android apps without any large scale build tool like Gradle, Buck or Bazel etc. Though, there are certain limitation of this build tool which are mentioned below.

## How can I use it in my Project:question:
Using Bacol is pretty straight-forward. But there are certain prerequisites and specified project structure which you have to ensure before using this tool script in your project. 

### And what are those prerequisites:question:
:one: You have bash supported OS.

:two: `ANDROID_HOME` enviornment variable is defined and contains a valid SDK installation.

:three: JDK is setup.

### Required Project Structure
Your project must have the following project strucutre in order for Bacol to recognize them.

```bash
├── src # contains java source code.
│   ├── com
│   │   ├── github
│   │   │   ├── amitkma
│   │   │   │   ├── helloandroid
├── res # contains android resources like colors, drawables, values etc.
│   ├── layout
│   ├── ...
│   └── values
├── libs # contains project dependencies.
│   ├── res-appcompat/
│   ├── UnitOf.jar
│   └── appcomapt-v7-23.1.1.jar
├── AndroidManifest.xml # Android Manifest file  
└── bacol.sh # Bacol Build Tool Script
```
- src: All your java related source code must go into this directory.
- res: Android related resources like colors, drawables, animations, and values, etc. must belong to this directory. 
- libs: If your project requires any dependency, put those into this directories. Currently, Bacol supports only jar libraries. If you want to use AAR libraries (for example, appcompat support library), extract the jar and resources from it and then put jar into `libs` and resources of AAR in a directory inside `libs`.
- bacol.sh: Copy/Download the `bacol.sh` from this project and add it in the root of your project.

### Using Bacol
Before executing Bacol, make sure you are in the root directory of the project.
```bash
chmod a+x bacol.sh // Make bacol.sh as executable
./bacol.sh --ks keystore.jks | --key key.pk8 --cert cert.x509.pem
```
Bacol takes the signing configuration (key or certificate option) as argument and it is necessary to provide atleast one signer_option. Read below for Key and Certificate options.

This part has been taken from [`apksigner`](https://developer.android.com/studio/command-line/apksigner#options-sign-key-cert)
#### Key and certificate options
`--ks <filename>`
The signer's private key and certificate chain reside in the given Java-based KeyStore file. If the filename is set to "NONE", the KeyStore containing the key and certificate doesn't need a file specified, which is the case for some PKCS #11 KeyStores.

`--ks-key-alias <alias>`
The name of the alias that represents the signer's private key and certificate data within the KeyStore. If the KeyStore associated with the signer contains multiple keys, you must specify this option.

`--ks-pass <input-format>`
The password for the KeyStore that contains the signer's private key and certificate. You must provide a password to open a KeyStore. The apksigner tool supports the following formats:

- `pass:<password>` – Password provided inline with the rest of the apksigner sign command.
- `env:<name>` – Password is stored in the given environment variable.
- `file:<filename>` – Password is stored as a single line in the given file.
- `stdin` – Password is provided as a single line in the standard input stream. This is the default behavior for --ks-pass

`--pass-encoding <charset>`

Includes the specified character encodings (such as, ibm437 or utf-8) when trying to handle passwords containing non-ASCII characters.
Keytool often encrypts keystores by converting the password using the console's default charset. By default, apksigner tries to decrypt using several forms of the password: the Unicode form, the form encoded using the JVM default charset, and, on Java 8 and older, the form encoded using the console's default charset. On Java 9, apksigner cannot detect the console's charset. So, you may need to specify --pass-encoding when a non-ASCII password is used. You may also need to specify this option with keystores that keytool created on a different OS or in a different locale.

`--key-pass <input-format>`

The password for the signer's private key, which is needed if the private key is password-protected. The apksigner tool supports the following formats:

- `pass:<password>` – Password provided inline with the rest of the apksigner sign command.
- `env:<name>` – Password is stored in the given environment variable.
- `file:<filename>` – Password is stored as a single line in the given file.
- `stdin` – Password is provided as a single line in the standard input stream. This is the default behavior for --key-pass

`--ks-type <algorithm>`

The type or algorithm associated with the KeyStore that contains the signer's private key and certificate. By default, apksigner uses the type defined as the keystore.type constant in the Security properties file.

`--ks-provider-name <name>`

The name of the JCA Provider to use when requesting the signer's KeyStore implementation. By default, apksigner uses the highest-priority provider.

`--ks-provider-class <class-name>`

The fully-qualified class name of the JCA Provider to use when requesting the signer's KeyStore implementation. This option serves as an alternative for --ks-provider-name. By default, apksigner uses the provider specified with the --ks-provider-name option.

`--ks-provider-arg <value>`
A string value to pass in as the argument for the constructor of the JCA Provider class; the class itself is defined with the --ks-provider-class option. By default, apksigner uses the class's 0-argument constructor.

`--key <filename>`

The name of the file that contains the signer's private key. This file must use the PKCS #8 DER format. If the key is password-protected, apksigner prompts for the password using standard input unless you specify a different kind of input format using the --key-pass option.

`--cert <filename>`

The name of the file that contains the signer's certificate chain. This file must use the X.509 PEM or DER format.

#### Examples
- `./bacol.sh --ks /home/amit/.android/debug.keystore --ks-pass pass:android`
- `./bacol.sh --key /home/amit/test/key.pk8 --cert /home/amit/test/cert.x509.pem`

On successful execution of bacol, you can find the signed apk in `out` directory of the project.

## What are the limitations of Bacol:question:
1. Currently it doesn't support incremental compilation.
2. AARs are not directly supported.
3. Slow when compiling a large project.
4. No kotlin support
5. Code generation at compile time using annotations doesn't work.
6. You can't specify the compileSdkVersion. Bacol currently picks the latest available in your SDK.
7. Required a fix project structure. 

## Future prospects in priority order.
- [ ] Support Kotlin and AARs
- [ ] Perform incremental compilation
- [ ] Respect annotations and code generation
- [ ] Allow user to select compileSdk.

## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/amitkma/Bacol.
