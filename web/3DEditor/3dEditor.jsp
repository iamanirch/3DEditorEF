<!doctype html>
<html lang="en">
    <head>
        <title>3D Model Editor</title>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, user-scalable=no, minimum-scale=1.0, maximum-scale=1.0">
        <link rel=stylesheet href="css/base.css"/>
        <script>
            var fileName;
            var filename;
            var fileType;
            function func()
            {
                fileName = document.getElementById("fileinput").files[0].name;
                filename = fileName.replace(/^.*\\/, "");
            }
            function func1()
            {
                document.getElementById("hidden").value = filename;
            }
        </script>
    </head>
    <body>
        <script src="js/Three.js"></script>
        <script src="js/Detector.js"></script>
        <script src="js/STLLoader.js"></script>
        <script src="js/FileSaver.js"></script>    
        <script src="js/OrbitControls.js"></script>
        <script src="js/jquery-2.1.0.min.js"></script>
        <script src="js/THREEx.FullScreen.js"></script>
        <script src="js/THREEx.KeyboardState.js"></script>
        <div id="ThreeJS" style="position: relative;top: 4px"></div>
        <img src="images/axis1.jpg" align="left" onclick="rotate1()" class="HoverBorder1"/>
        <img src="images/axis2.jpg" align="left" onclick="rotate2()" class="HoverBorder1"/>
        <img src="images/axis3.jpg" align="left" onclick="rotate3()" class="HoverBorder1"/>
        <img src="images/axis4.jpg" align="left" onclick="rotate4()" class="HoverBorder1"/>
        <img src="images/axis5.jpg" align="left" onclick="rotate5()" class="HoverBorder1"/>
        <img src="images/axis6.jpg" align="left" onclick="rotate6()" class="HoverBorder1"/>
        <img src="images/setOrigin.jpg" align="left" onclick="setOrigin()" class="HoverBorder1"/>

        <table border="0" width="48%" style="position: relative;top: -312px; left: 20px; border-collapse: collapse">
            <tr>
                <td>
                    <p align="left">
                        <b>Transformation:</b> Add value in the coordinate boxes given below, click the transformation required.<br/><br/>
                        <b>Extrude:</b> Click on 3D model to select any plane and click extrude.<br/><br/>
                        <b>Reset/Download:</b> use these functions to restore or saving the model.<br/>
                    </p>            
                </td>
            </tr>
            <tr>
                <td>

                    <form action="../upload"  method="post" ENCTYPE='multipart/form-data' name="MyForm">
                        Select Model: <input type="file" id="fileinput" value="" name="file" onchange="func(this);" size="2"/>
                        <script>
                            var abc;
                            function readSingleFile(evt) {
                                var f = evt.target.files[0];
                                if (f) {
                                    var r = new FileReader();
                                    r.onload = function(e) {
                                        var contents = e.target.result;
                                        abc = contents.substr(0, contents.indexOf("f"));
                                        document.getElementById("hidden1").value = abc;
                                    }
                                    r.readAsText(f);
                                } else {
                                    alert("Failed to load file");
                                }
                            }
                            document.getElementById('fileinput').addEventListener('change', readSingleFile, false);
                        </script>
                        <input type="hidden" name="hidden" id="hidden" value=""/>
                        <input type="hidden" name="hidden1" id="hidden1" value=""/>
                        <input type="submit" value="Upload" onclick="func1()" style="position: relative; left: -35px;"/><br/>
                    </form>

                </td>
            </tr>
            <tr>
                <td align="center">
                    <fieldset style="width:320px">
                        <fieldset style="width:250px;">
                            X=<input type="text" id="xvalue" size="4"/> 
                            Y=<input type="text" id="yvalue" size="4"/> 
                            Z=<input type="text" id="zvalue" size="4"/>
                        </fieldset>
                        <br/>
                        <input type="radio" name="modelEdit" id="move" onclick="move()"><label for="move">Move</label>          
                        <input type="radio" name="modelEdit" id="scale" onclick="scale()"><label for="scale">Scale</label>
                        <input type="radio" name="modelEdit" id="rotate" onclick="rotate()"><label for="rotate">Rotate</label>
                        <br/><br/>
                        <input type="text" id="extrVal" placeholder="Add value (+/-)" size="11" class="HoverBorder" style="position: relative;left: 5px;"/>
                       
                        <img src="images/extrude.jpg" onclick="extrude()" class="HoverBorder" style="position: relative; top: 10px"/>
                        <br/><br/>
                        <img src="images/reset.jpg" onclick="reset()" class="HoverBorder"/>
                        
                        <img src="images/download.jpg" onclick="saveSTL()" class="HoverBorder"/>
                    </fieldset>
                </td>       
            </tr>
        </table>

        <script>
	
// MAIN

// standard global variables
var container, scene,loader, camera, renderer, controls, stats;
var keyboard = new THREEx.KeyboardState();

// custom global variables
var geometry = new THREE.Geometry();
var targetList =[], intersects = [];
var projector, mouse = { x: 0, y: 0 }, INTERSECTED;
var indexFaceArr = [], indexNormArr =[], intNormal, selectedFaces = [],colorSwitch = [];
var totalFaceCount = 0,totalVertexCount = 0;
var mouseSphereCoords = null;
var mouseSphere=[];

init();
render();

// FUNCTIONS        
function init() 
{
	// SCENE
	scene = new THREE.Scene();
	// CAMERA 
	var SCREEN_WIDTH = 600, SCREEN_HEIGHT = 600;
	var VIEW_ANGLE = 45, ASPECT = SCREEN_WIDTH / SCREEN_HEIGHT, NEAR = 0.1, FAR = 20000;
	camera = new THREE.PerspectiveCamera( VIEW_ANGLE, ASPECT, NEAR, FAR);
	scene.add(camera);
	camera.position.set(250,250,250);
	camera.lookAt(scene.position);  
	// RENDERER
	if ( Detector.webgl )
		renderer = new THREE.WebGLRenderer( {antialias:true} );
	else
		renderer = new THREE.CanvasRenderer(); 
	renderer.setSize(SCREEN_WIDTH, SCREEN_HEIGHT);
	container = document.getElementById( 'ThreeJS' );
	container.appendChild( renderer.domElement );
	// EVENTSx
	THREEx.FullScreen.bindKey({ charCode : 'f'.charCodeAt(0) });
	// CONTROLS 
	controls = new THREE.OrbitControls( camera, renderer.domElement );
	// LIGHT
	//var light = new THREE.HemisphereLight(0x777777); 
	//scene.add(light);
	var light = new THREE.AmbientLight( 0x777777 ); // soft white light
	scene.add( light );
	var light = new THREE.PointLight(0x777777,1,4500);
	light.position.set(-300,1000,-300);
	scene.add(light);
	// AXES
	var axes = new THREE.AxisHelper(100);
	axes.position.set(0,0,0);
	scene.add(axes);
	////////////
	//CUSTOM//
	////////////
	addMesh();
	var newSphereGeom= new THREE.SphereGeometry(3,3,3);
	var sphere= new THREE.Mesh(newSphereGeom, new THREE.MeshBasicMaterial({ color: 0x2266dd }));
	scene.add(sphere);
	mouseSphere.push(sphere);
	// PROJECTOR
	projector = new THREE.Projector();
	//EVENT LISTENERS
	container.addEventListener( 'mousedown', onDocumentMouseDown, false );
	container.addEventListener( 'mousemove', onDocumentMouseMove, false );
	// STATS BOX//
	stats = document.createElement("div");
	stats.id = "statistics";
	stats.style.cssText = "position:absolute; width:100px; height:50px; text-align: left; left:15px; top:15px; font:13px Courier New; color:red; background:transparent;";
	container.appendChild( stats );
}
	
// Adds new meshes to the scene; also used for reset function
function addMesh()
{
	loader = new THREE.STLLoader();
	loader.addEventListener( 'load', function ( event ) {
	geometry = event.content;
	geometry.mergeVertices();
	
	faces = geometry.faces;
	vertices = geometry.vertices;
	for(var i=0; i<faces.length;i++)
		colorSwitch[i] = 0;
	newMesh(geometry);
	
	totalFaceCount = faces.length;
	totalVertexCount = vertices.length;
	stats.innerHTML = ' Verts=' +totalVertexCount.toString() + ',Faces=' + totalFaceCount.toString();
	});
	loader.load('Model/1050.STL');
}

function newMesh(geom)
{
	mesh = new THREE.Mesh( geom, new THREE.MeshLambertMaterial( { color: 0xffffff, vertexColors: THREE.FaceColors } ));
	scene.add(mesh);
	//wireMesh = new THREE.Mesh(geom, new THREE.MeshBasicMaterial({ color: 0x000000, wireframe: true }));
	//mesh.add( wireMesh );
	targetList.push(mesh);
}

function onDocumentMouseMove( event ) 
{
	mouse.x = ( event.clientX / 600 ) * 2 - 1;
	mouse.y = - ( event.clientY / 600 ) * 2 + 1;
}

function onDocumentMouseDown( event )
{
	console.log("Click.");
	mouse.x = ( event.clientX / 600  ) * 2 - 1;
	mouse.y = - ( event.clientY / 600 ) * 2 + 1;
	
	var Feature = $("input[type='radio'][name='modelSelect']:checked").val();
	if("P" === Feature)
		planeSelection();
	else if("C" === Feature)
		circleSelection();
}
	
function initCaster(){
	//test items in selected faces array
	var vector = new THREE.Vector3( mouse.x, mouse.y, 1 );
	projector.unprojectVector( vector, camera );
	var ray = new THREE.Raycaster( camera.position, vector.sub( camera.position ).normalize() );

	intersects = ray.intersectObjects( targetList );
}

function checkSelection(select){
	for(var i=0; i<select.length;i++){
		if(colorSwitch[select[i]] === 1)
			colorSwitch[select[i]] = 0;
		else if(colorSwitch[select[i]] === 0)
			colorSwitch[select[i]] = 1;
	}
}

function CheckMouseSphere(){
	if(intersects.length > 0){
		mouseSphereCoords = [intersects[0].point.x, intersects[0].point.y, intersects[0].point.z];
	}
	else{
		mouseSphereCoords = null;
	}
	// if the coordinates exist, make the sphere visible
	if(mouseSphereCoords !== null){
		mouseSphere[0].position.set(mouseSphereCoords[0],mouseSphereCoords[1],mouseSphereCoords[2]);
		mouseSphere[0].visible = true;
	}
	else{ 
		mouseSphere[0].visible = false;
	}
}
	
////////////////////////////////////////////////////////////////////////////////
//ALL PLANE AND FEATURE IDENTIFICATION FUNCTIONS//
////////////////////////////////////////////////////////////////////////////////

// Checking faces for selection and highlighting them
function planeSelection() { 
	// initCaster();
	if ( intersects.length > 0 )
	{
		//normal condition applied
		indexNormArr= [];
		intNormal = intersects[0].face.normal;
		for(var i=0; i< faces.length; i++)
		{
			if( compareVector(faces[i].normal, intersects[0].face.normal))
				indexNormArr.push(i);
		}
		//Recursion applied
		selectedFaces = [];
		selectedFaces = planeRecur(indexNormArr, intersects[0].face);
		checkSelection(selectedFaces);
		updateColor(colorSwitch);
	}
}
	
// Recursive function to find plane from initial face.
var planeRecur = function (faceArr, faceMatch ){
	var temp;
	for(var i =0; i<faceArr.length; i++){
		if(compareFaces( faces[faceArr[i]], faceMatch) !== 0) {
			temp = faceArr[i];
			faceArr.splice(i,1);
			selectedFaces.push(temp);
			planeRecur( faceArr, faces[temp]);
		}
	} 
	selectedFaces = selectedFaces.getUnique();  
	selectedFaces.sort(function(a, b){return a - b});
	return selectedFaces;
};

// Selecting Circular Features
function circleSelection(){
	intNormal = intersects[0].face.normal;
	for(var i=0; i< faces.length; i++) indexFaceArr.push(i);    
	//Recursion applied 
	selectedFaces = [];
	selectedFaces = circleRecur(indexFaceArr, intersects[0].face);
	checkSelection(selectedFaces);
	updateColor(colorSwitch);
}

//Recursive function to extract circular feature
var circleRecur = function (faceArr, faceMatch ){
	var temp;
	for(var i =0; i<faceArr.length; i++){
		if( compareFaces( faces[faceArr[i]], faceMatch) === 2 && Math.round(dotProdVector( faces[faceArr[i]].normal, faceMatch.normal)) !== 0 ) {
			temp = faceArr[i];
			faceArr.splice(i,1);
			selectedFaces.push(temp);
			circleRecur( faceArr, faces[temp]);
		}
	}
	selectedFaces = selectedFaces.getUnique();  
	selectedFaces.sort(function(a, b){return a - b});
	return selectedFaces;
};

////////////////////////////////////////////////////////////////////////////////
//ALL EDITING FUNCTIONS//
////////////////////////////////////////////////////////////////////////////////

function scale(){
	var Sx = parseFloat(document.getElementById('xvalue').value);
	var Sy = parseFloat(document.getElementById('yvalue').value);
	var Sz = parseFloat(document.getElementById('zvalue').value);
	if (isNaN(Sx)){Sx = 1;} if (isNaN(Sy)){Sy = 1;} if (isNaN(Sz)){Sz = 1;} 
	mesh.scale.set(Sx,Sy,Sz);
}

function move(){
	var Mx = parseFloat(document.getElementById('xvalue').value);
	var My = parseFloat(document.getElementById('yvalue').value);
	var Mz = parseFloat(document.getElementById('zvalue').value);
	if (isNaN(Mx)){Mx = 0;} if (isNaN(My)){My = 0;} if (isNaN(Mz)){Mz = 0;} 
	mesh.position.x += Mx;
	mesh.position.y += My;
	mesh.position.z += Mz;
}

function rotate(){
	var pi = Math.PI;
	var Ax = pi * (parseFloat(document.getElementById('xvalue').value) / 180);
	var Ay = pi * (parseFloat(document.getElementById('yvalue').value) / 180);
	var Az = pi * (parseFloat(document.getElementById('zvalue').value) / 180);
	if (isNaN(Ax)){Ax = 0;} if (isNaN(Ay)){Ay = 0;} if (isNaN(Az)){Az = 0;}
	mesh.rotation.x += Ax;
	mesh.rotation.y += Ay;
	mesh.rotation.z += Az;
}

function extrude(){
	var count = 0;
	for(var i=0; i< colorSwitch.length; i++) count+= colorSwitch[i];
	if(count > 0)
	{
		var val = parseFloat(document.getElementById('extrVal').value);
		var vertArr = [];
		for(var i=0; i<selectedFaces.length; i++){
			if( colorSwitch[selectedFaces[i]] === 1 ){
				vertArr.push(faces[selectedFaces[i]].a);
				vertArr.push(faces[selectedFaces[i]].b);
				vertArr.push(faces[selectedFaces[i]].c);
			}
		}
		vertArr = vertArr.getUnique();
		vertArr.sort(function(a, b){return a - b});
		for(var i=0; i<vertArr.length; i++){
			vertices[vertArr[i]].x += val * intNormal.x;
			vertices[vertArr[i]].y += val * intNormal.y;
			vertices[vertArr[i]].z += val * intNormal.z;
		}
	}
	else
		alert('Please select a plane!!');
	geometry.verticesNeedUpdate = true;
}
	
function setOrigin(){
	mesh.position.set(0,0,0);
}

function reset(){
	if(intersects.length > 0){
		intersects = []; 
	}
	for(var i=0; i< colorSwitch; i++)
		colorSwitch[i] = 0;
	updateColor(colorSwitch);
	scene.remove(mesh);
	addMesh();
}
	
////////////////////////////////////////////////////////////////////////////////
// AUXILLARY FUNCTIONS //
////////////////////////////////////////////////////////////////////////////////

function compareVector(vec1, vec2){
	if(vec1.x === vec2.x && vec1.y === vec2.y && vec1.z === vec2.z)
		return true;
	else
		return false;
}

function compareFaces(face1, face2){
	var key = ['a', 'b', 'c'],cnt = 0; 
	for(var i=0; i<3; i++){
		for(var j=0; j< 3; j++){
			if( face1[key[i]] === face2[key[j]] )
				cnt++;
		}
	}
	return cnt;
}

function dotProdVector(vec1, vec2){
	var mulv = vec1.x*vec2.x + vec1.y*vec2.y + vec1.z*vec2.z;
	return mulv.toPrecision(4);
}

function crossProdVector(vec1, vec2){
	var vector = new THREE.Vector3();
	vector.x =  vec1.y * vec2.z - vec1.z * vec2.y;
	vector.y = -vec1.x * vec2.z + vec1.z * vec2.x;
	vector.z =  vec1.x * vec2.y - vec1.y * vec2.x;
	return vector;
}

//Calculates distance between centroids of two faces
function planeCentreDistance(face1, face2){
	var centre1 = face1.centroid;
	var centre2 = face2.centroid;
	return (Math.sqrt(Math.pow( (centre1.x - centre2.x) ,2))+ 
					(Math.pow( (centre1.y - centre2.y) ,2))+
					(Math.pow( (centre1.z - centre2.z) ,2))).toPrecision(5);
}
	
function toString(v) { return "[ " + v.x + ", " + v.y + ", " + v.z + " ]"; }

function render() 
{
	requestAnimationFrame( render );
	renderer.render( scene, camera );       
	update();
}

function update()
{
	initCaster();
	CheckMouseSphere();
	controls.update();
}

// Updates plane colors 
function updateColor(colorSwitch){
	for(var i=0; i< colorSwitch.length; i++){
		if(colorSwitch[i] === 1)
			faces[i].color.setRGB(1,0,0);
		else
			faces[i].color.setRGB(1,1,1);
	}
	geometry.colorsNeedUpdate = true;
}

// Return unique values inside array
Array.prototype.getUnique = function(){
	var u = {}, a = [];
	for (var i = 0, l = this.length; i < l; ++i){
		if (u.hasOwnProperty(this[i])) {
			continue;
	}
	a.push(this[i]);
	u[this[i]] = 1;
	}
	return a;
};

$(document).ready(function() {
	$('input[name="modelEdit"]').prop('checked', false);
	$('input[name="modelSelect"]').prop('checked', false);
});
	
function testSelect(){
	var f = parseInt(document.getElementById('test').value);
	faces[f].color.setRGB(0,1,0);
	console.log( faces[f].centroid  );
	geometry.colorsNeedUpdate = true;
}

////////////////////////////////////////////////////////////////////////////////
// SAVE STL FILE //
////////////////////////////////////////////////////////////////////////////////

function stringifyVertex(vec){
	return "         vertex "+vec.x.toPrecision(10)+" "+vec.y.toPrecision(10) +" "+vec.z.toPrecision(10)+"\n";;
}

function stringifyNormal(vec){
	return vec.x.toPrecision(10) +" "+vec.y.toPrecision(10) +" "+vec.z.toPrecision(10)+"\n";
}

// Given a THREE.Geometry, create an STL string
function generateSTL(geo){
	var verts = geo.vertices;
	var tris  = geo.faces;

	var stl = "solid pixel\n";
	for(var i = 0; i<tris.length; i++){
		stl += ("   facet normal "+stringifyNormal( tris[i].normal ));
		stl += ("      outer loop\n");
		stl += stringifyVertex( verts[ tris[i].a ]);
		stl += stringifyVertex( verts[ tris[i].b ]);
		stl += stringifyVertex( verts[ tris[i].c ]);
		stl += ("      endloop\n");
		stl += ("   endfacet\n");
	}
	stl += ("endsolid");
	return stl;
}

// Use FileSaver.js 'saveAs' function to save the string
function saveSTL( ){  
	var stlString = generateSTL( geometry );
	var blob = new Blob([stlString], {type: 'text/plain'});
	saveAs(blob, name + 'CHACHA.stl');
}

</script>
    </body>
</html>
