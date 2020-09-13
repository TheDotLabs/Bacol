#!/bin/bash

sign_args=$*

rm -rf gen obj compiled_res out

if [[ -z "${ANDROID_HOME}" ]]; then
	echo "{ANDROID_HOME} path variable is not set. Set it to point Android SDK."
	exit 1
else
	build_tools_dir=$ANDROID_HOME/build-tools/
	declare -a build_tools
	for f in $build_tools_dir*;
	do
		if [ -d "$f" ]; then
			build_tools+=($(basename $f))
    	fi
	done
	if [ ${#build_tools[@]} -eq 0 ]; then
		echo "No build-tools found at $build_tools_dir. Make sure you've atleast one build tools downloaded."
		exit 1
	else 
		sorted_build_tools=($(for l in ${build_tools[@]}; do echo $l; done | sort))
		echo "Available build-tools are ${sorted_build_tools[@]}"
		latest_build_tool=${sorted_build_tools[${#sorted_build_tools[@]}-1]}
		echo "Using latest build tool available: $latest_build_tool"
	fi
fi

latest_build_tool_dir="$build_tools_dir$latest_build_tool"
aapt2="${latest_build_tool_dir}/aapt2"
d8="${latest_build_tool_dir}/d8"
zipalign="${latest_build_tool_dir}/zipalign"
apksigner="${latest_build_tool_dir}/apksigner"

if ! aapt_command="$(type -p $aapt2)" || [[ -z $aapt_command ]]; then
	echo "AAPT2 is not found in $latest_build_tool_dir"
	exit 1
fi

echo "Processing resources using Android Asset Packaging Tool (AAPT2)"
mkdir gen
mkdir compiled_res
mkdir out

## Compiling app resources.
$aapt2 compile --dir res -o compiled_res/resources.zip

## Compiling library resources. Make sure they are direct child of libs directory inside root directory of project.
for f in libs/*; do
		if [ -d "$f" ]; then
			$aapt2 compile --dir $f -o compiled_res/$(basename "$f").zip
    	fi
done

## Linking resources.
platforms_dir=$ANDROID_HOME/platforms/
declare -a platforms
for f in $platforms_dir*;
do
	if [ -d "$f" ]; then
		platforms+=($(basename $f))
	fi
done
if [ ${#platforms[@]} -eq 0 ]; then
	echo "No platforms found at $platforms_dir. Make sure you've atleast one platform downloaded."
	exit 1
else 
	sorted_platforms=($(for l in ${platforms[@]}; do echo $l; done | sort))
	echo "Available platforms are ${sorted_platforms[@]}"
	latest_platform=${sorted_platforms[${#sorted_platforms[@]}-1]}
	echo "Using latest platform available: $latest_platform"
fi


compiled_resources=""
for f in compiled_res/*; do
	echo $f
	compiled_resources+="$f "
done

$aapt2 link $compiled_resources -I $platforms_dir/$latest_platform/android.jar \
 --auto-add-overlay \
 --manifest AndroidManifest.xml \
 --java gen \
 -o out/res.apk

if [ $? -ne 0 ]; then
	echo "Resource linking failed. Fix the errors encountered above."
	exit 2
fi

rm -rf compiled_res
 
for i in libs/*.jar; do
	libs="$libs:$i"
	dxlibs="$dxlibs $i"
	d8libs="$d8libs --classpath $i"
done
libs="${libs#:}"

echo "Compiling source files"
mkdir obj
javac -source 1.8 \
	-target 1.8 \
	-bootclasspath $platforms_dir/$latest_platform/android.jar \
	-cp $libs \
	-d obj \
	$(find src gen -type f -name '*.java')

if [ $? -ne 0 ]; then
	echo "Java compilation failed. Fix the errors encountered above."
	exit 2
fi

rm -rf gen

if ! d8_command="$(type -p $d8)" || [[ -z $d8_command ]]; then
	echo "d8 is not found in $latest_build_tool_dir"
	exit 1
fi
 
echo "Dexing class files"
rm -rf dex
mkdir dex
$d8 $(find obj -type f -name '*.class') $dxlibs --release \
	--classpath $platforms_dir/$latest_platform/android.jar \
	--lib $platforms_dir/$latest_platform/android.jar \
	--output dex

if [ $? -ne 0 ]; then
	echo "Dexing failed. Fix the errors encountered above."
	exit 2
else 
	echo "Dexing completed."
fi

rm -rf obj


echo "Creating unsigned apk"
zip -uj out/res.apk dex/classes.dex

if [ $? -ne 0 ]
then
   echo "An error occurred while ziping the resources and dex files, Make sure you have zip installed."
   exit 1
fi

rm -rf dex

if ! zipalign_command="$(type -p $zipalign)" || [[ -z $zipalign_command ]]; then
	echo "zipalign is not found in $latest_build_tool_dir"
	exit 1
fi

$zipalign -f 4 out/res.apk out/app_unsigned.apk
rm -f out/res.apk

echo "Signing apk"
if ! apksigner_command="$(type -p $apksigner)" || [[ -z $apksigner_command ]]; then
	echo "apksigner is not found in $latest_build_tool_dir"
	exit 1
fi

$apksigner sign $sign_args --out out/app_signed.apk out/app_unsigned.apk

if [ $? -ne 0 ]
then
   echo "An error occurred while signing the apk, Exiting."
   rm -f out/app_unsigned.apk
   exit 1
else
	echo "Apk generated successfully at out/app_signed.apk"
	rm -f out/app_unsigned.apk
	exit 0
fi

