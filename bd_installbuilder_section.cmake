file(APPEND "${CMAKE_ARGV3}"
"<component>
	<name>${CMAKE_ARGV4}</name>
	<canBeEdited>1</canBeEdited>
	<selected>0</selected>
	<show>1</show>
	<folderList>
		<folder>
			<name>${CMAKE_ARGV4}</name>
			<destination>\${${CMAKE_ARGV5}}</destination>
			<distributionFileList>
				<distributionFile origin=\"${CMAKE_ARGV6}\" />
			</distributionFileList>
		</folder>
	</folderList>
</component>
")
