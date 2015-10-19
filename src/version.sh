
VERSION=0.2.2
BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)
VERSION_FILE=VersionInfo.swift

echo "// THIS IS A GENERATED FILE\n" > $VERSION_FILE
echo "enum VersionInfo : String {" >> $VERSION_FILE
echo "    case Version = \"$VERSION\"" >> $VERSION_FILE
echo "    case Branch = \"$BRANCH_NAME\"" >> $VERSION_FILE
echo "}" >> $VERSION_FILE
