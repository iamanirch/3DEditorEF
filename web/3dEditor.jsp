<!doctype html>
<html lang="en">
    <head>
        <title>3D Model Editor</title>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, user-scalable=no, minimum-scale=1.0, maximum-scale=1.0">
        <link rel=stylesheet href="3DEditor/css/base.css"/>
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
        <script src="3DEditor/js/Three.js"></script>
        <script src="3DEditor/js/Detector.js"></script>
        <script src="3DEditor/js/Scene.js"></script>
        <script src="3DEditor/js/Geometry.js"></script>
        <script src="3DEditor/js/GeometryUtils.js"></script>
        <script src="3DEditor/js/OrbitControls.js"></script>
        <script src="3DEditor/js/STLLoader.js"></script>
        <script src="3DEditor/js/THREEx.KeyboardState.js"></script>
        <script src="3DEditor/js/THREEx.FullScreen.js"></script>
        <script src="3DEditor/js/THREEx.WindowResize.js"></script>
        <script src="3DEditor/js/jquery-2.1.0.min.js"></script>
        <script src="3DEditor/js/FileSaver.js"></script>
        <div id="ThreeJS" style="position: relative;top: 4px"></div>
        <img src="3DEditor/images/axis1.jpg" align="left" onclick="rotate1()" class="HoverBorder1"/>
        <img src="3DEditor/images/axis2.jpg" align="left" onclick="rotate2()" class="HoverBorder1"/>
        <img src="3DEditor/images/axis3.jpg" align="left" onclick="rotate3()" class="HoverBorder1"/>
        <img src="3DEditor/images/axis4.jpg" align="left" onclick="rotate4()" class="HoverBorder1"/>
        <img src="3DEditor/images/axis5.jpg" align="left" onclick="rotate5()" class="HoverBorder1"/>
        <img src="3DEditor/images/axis6.jpg" align="left" onclick="rotate6()" class="HoverBorder1"/>
        <img src="3DEditor/images/setOrigin.jpg" align="left" onclick="setOrigin()" class="HoverBorder1"/>

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

                    <form action="upload"  method="post" ENCTYPE='multipart/form-data' name="MyForm">
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
                       
                        <img src="3DEditor/images/extrude.jpg" onclick="extrude()" class="HoverBorder" style="position: relative; top: 10px"/>
                        <br/><br/>
                        <img src="3DEditor/images/reset.jpg" onclick="reset()" class="HoverBorder"/>
                        
                        <img src="3DEditor/images/download.jpg" onclick="saveSTL()" class="HoverBorder"/>
                    </fieldset>
                </td>       
            </tr>
        </table>

        <script>

            // MAIN

            // standard global variables
            var container, projector, scene, loader, camera, renderer, controls, stats;
            var keyboard = new THREEx.KeyboardState();

            // custom global variables
            var geometry = new THREE.Geometry();
            var targetList = [], intersects = [];
            var mouse = {x: 0, y: 0};
            var indexFaceArr = [], intNormal, planeSelect = [];
            var totalFaceCount = 0, totalVertexCount = 0;
            var mouseSphere = [];
            var tes = '<%= (String) request.getAttribute("f2") %>';
            console.log(tes);
    init();
            render();

            // FUNCTIONS 		
            function init()
            {
                // SCENE
                scene = new THREE.Scene();

                // CAMERA 
                var SCREEN_WIDTH = 350, SCREEN_HEIGHT = 300;
                var VIEW_ANGLE = 45, ASPECT = SCREEN_WIDTH / SCREEN_HEIGHT, NEAR = 0.1, FAR = 20000;
                camera = new THREE.PerspectiveCamera(VIEW_ANGLE, ASPECT, NEAR, FAR);
                scene.add(camera);
                camera.position.set(700, 500, 500);
                camera.lookAt(scene.position);

                // RENDERER
                if (Detector.webgl)
                    renderer = new THREE.WebGLRenderer({antialias: true});
                else
                    renderer = new THREE.CanvasRenderer();
                renderer.setSize(SCREEN_WIDTH, SCREEN_HEIGHT);
                container = document.getElementById('ThreeJS');
                container.appendChild(renderer.domElement);

                // EVENTSx
                THREEx.FullScreen.bindKey({charCode: 'f'.charCodeAt(0)});

                // CONTROLS
                controls = new THREE.OrbitControls(camera, renderer.domElement);

                // LIGHT
                var light = new THREE.HemisphereLight(0x777777);
                scene.add(light);

                // AXES
                var axes = new THREE.AxisHelper(100);
                axes.position.set(0, 0, 0);
                scene.add(axes);

                ////////////
                //STL Load//
                ////////////
                addMesh();

                // initialize object to perform world/screen calculations
                projector = new THREE.Projector();

                // when the mouse moves, call the given function
                container.addEventListener('mousedown', onDocumentMouseDown, false);
                //container.addEventListener( 'mousemove', onDocumentMouseMove, false );

                // STATS BOX//
                stats = document.createElement("div");
                stats.id = "statistics";
                stats.style.cssText = "position:absolute; width:100px; height:50px; text-align: left; left:10px; top:10px; font:12px Courier New; color:red; background:transparent;";
                container.appendChild(stats);
            }

            // Adds new meshes to the scene; also used for reset function
            function addMesh()
            {
                loader = new THREE.STLLoader();
                loader.addEventListener('load', function(event) {
                    geometry = event.content;
                    geometry.mergeVertices();

                    newMesh(geometry);

                    totalFaceCount = geometry.faces.length;
                    totalVertexCount = geometry.vertices.length;
                    stats.innerHTML = totalVertexCount.toString() + ' vertices' + '<br/>' + totalFaceCount.toString() + ' facets';
                });
                
                loader.load('3DEditor/Model/'+tes);
                console.log('3DEditor/Model/'+tes);
            }

            function newMesh(geom)
            {
                mesh = new THREE.Mesh(geom, new THREE.MeshLambertMaterial({color: 0xffffff, vertexColors: THREE.FaceColors}));
                scene.add(mesh);
                wireMesh = new THREE.Mesh(geom, new THREE.MeshBasicMaterial({color: 0x000000, wireframe: true}));
                //mesh.add( wireMesh );
                targetList.push(mesh);
            }
            /*
             function onDocumentMouseMove( event ) 
             {
             mouse.x = ( event.clientX / 400 ) * 2 - 1;
             mouse.y = - ( event.clientY / 300 ) * 2 + 1;
             }
             */
            function onDocumentMouseDown(event)
            {
                console.log("Click.");
                mouse.x = (event.clientX / 350) * 2 - 1;
                mouse.y = -(event.clientY / 300) * 2 + 1;
                checkSelection();
            }

            // Checking faces for selection and highlighting them
            function checkSelection()
            {
                //test items in selected faces array
                intersects=[];
                var vector = new THREE.Vector3(mouse.x, mouse.y, 1);
                projector.unprojectVector(vector, camera);
                var ray = new THREE.Raycaster(camera.position, vector.sub(camera.position).normalize());
                intersects = ray.intersectObjects(targetList);
                if (intersects.length > 0)
                {
                    console.log("Hit @ " + toString(intersects[0].point));
                    intNormal = intersects[0].face.normal;
                    indexFaceArr=[];
                    for (var i = 0; i < geometry.faces.length; i++)
                    {
                        if (compare(geometry.faces[i].normal, intNormal))
                        {
                            if (intersects[0].faceIndex !== i)
                                indexFaceArr.push(i);
                        }
                    }
                    console.log(indexFaceArr);
                    planeSelect=[];
                    planeSelect = plane(intersects[0].face, indexFaceArr);
                    planeSelect.push(intersects[0].faceIndex);
                    updateColor(planeSelect);
                }
            }

            // Updates plane colors 
            function updateColor(indexArr) {
                if (indexArr.length > 0) {
                    for (var i = 0; i < indexArr.length; i++) {
                        geometry.faces[indexArr[i]].color.setRGB(1, 0, 0);
                    }
                }
                else {
                    for (var i = 0; i < geometry.faces.length; i++) {
                        geometry.faces[i].color.setRGB(1, 1, 1);
                    }
                }
                update();
            }

            // Extract intital plane from intersecting face
            function plane(intFace, newFaceArr) {
                var count = 0;
                var match1V = [], match0V = [];
                for (var n = 0; n < newFaceArr.length; n++) {
                    count = 0;
                    count = compareFaces(intFace, geometry.faces[ newFaceArr[n] ]);
                    if (count === 0)
                    {
                        match0V.push(newFaceArr[n]);
                    }
                    else if (count > 0)
                    {
                        match1V.push(newFaceArr[n]);
                    }
                }
                match1V = planeExtrapolate(match1V,match0V);
                return match1V;
            }

            // Extrapolate initial plane to find all triangles in a single plane
            function planeExtrapolate(match1, match0) {
                var i = 0, count2 = 0;
                while (i < match0.length) {
                    for (var j = 0; j < match1.length; j++) {
                        count2 += compareFaces(geometry.faces[ match1[j]], geometry.faces[ match0[i]]);
                    }
                    if (count2 > 0)
                    {
                        var temp = match0[i];
                        match0.splice(i, 1);
                        match1.push(temp);
                    }
                    else
                        i++;
                }
                return match1;
            }

            ////////////////////////////////////////////////////////////////////////////////
            //ALL EDITING FUNCTIONS//
            ////////////////////////////////////////////////////////////////////////////////

            function scale() {
                var Sx = parseFloat(document.getElementById('xvalue').value);
                var Sy = parseFloat(document.getElementById('yvalue').value);
                var Sz = parseFloat(document.getElementById('zvalue').value);
                if (isNaN(Sx)) {
                    Sx = 1;
                }
                if (isNaN(Sy)) {
                    Sy = 1;
                }
                if (isNaN(Sz)) {
                    Sz = 1;
                }
                mesh.scale.set(Sx, Sy, Sz);
            }

            function move() {
                var Mx = parseFloat(document.getElementById('xvalue').value);
                var My = parseFloat(document.getElementById('yvalue').value);
                var Mz = parseFloat(document.getElementById('zvalue').value);
                if (isNaN(Mx)) {
                    Mx = 0;
                }
                if (isNaN(My)) {
                    My = 0;
                }
                if (isNaN(Mz)) {
                    Mz = 0;
                }
                mesh.position.x += Mx;
                mesh.position.y += My;
                mesh.position.z += Mz;
            }

            function rotate() {
                pi = Math.PI;
                var Ax = pi * (parseFloat(document.getElementById('xvalue').value) / 180);
                var Ay = pi * (parseFloat(document.getElementById('yvalue').value) / 180);
                var Az = pi * (parseFloat(document.getElementById('zvalue').value) / 180);
                if (isNaN(Ax)) {
                    Ax = 0;
                }
                if (isNaN(Ay)) {
                    Ay = 0;
                }
                if (isNaN(Az)) {
                    Az = 0;
                }
                mesh.rotation.x += Ax;
                mesh.rotation.y += Ay;
                mesh.rotation.z += Az;
            }

            function extrude() {
                if (intersects.length > 0)
                {
                    var val = parseFloat(document.getElementById('extrVal').value);
                    var vertArr = [];
                    for (var i = 0; i < planeSelect.length; i++) {
                        vertArr.push(geometry.faces[planeSelect[i]].a);
                        vertArr.push(geometry.faces[planeSelect[i]].b);
                        vertArr.push(geometry.faces[planeSelect[i]].c);
                    }
                    vertArr = vertArr.getUnique();
                    vertArr.sort(function(a, b) {
                        return a - b
                    });
                    for (var i = 0; i < vertArr.length; i++) {
                        geometry.vertices[vertArr[i]].x += val * intNormal.x;
                        geometry.vertices[vertArr[i]].y += val * intNormal.y;
                        geometry.vertices[vertArr[i]].z += val * intNormal.z;
                    }
                }
                else
                {
                    alert('Please select a plane!!');
                }
                update();
            }

            function setOrigin() {
                mesh.position.set(0, 0, 0);
            }

            function reset() {
                if (intersects.length > 0) {
                intersects = [];
                }console.log(intersects);
                planeSelect = [];
                updateColor(planeSelect);
                scene.remove(mesh);
                addMesh();
            }

            function rotate1() {
                mesh.rotation.set(-45, 0, 0);
            }
            function rotate2() {
                mesh.rotation.set(45, 0, 0);
            }
            function rotate3() {
                mesh.rotation.set(0, 0, -45);
            }
            function rotate4() {
                mesh.rotation.set(0, 0, 45);
            }
            function rotate5() {
                mesh.rotation.set(0, 45, 0);
            }
            function rotate6() {
                mesh.rotation.set(0, -45, 0);
            }
            ////////////////////////////////////////////////////////////////////////////////
            // AUXILLARY FUNCTIONS //
            ////////////////////////////////////////////////////////////////////////////////

            function compare(vec1, vec2) {
                if (vec1.x === vec2.x && vec1.y === vec2.y && vec1.z === vec2.z)
                    return true;
                else
                    return false;
            }

            function compareFaces(face1, face2) {
                var key = ['a', 'b', 'c'], cnt = 0;
                for (var i = 0; i < 3; i++) {
                    for (var j = 0; j < 3; j++) {
                        if (face1[key[i]] === face2[key[j]])
                            cnt++;
                    }
                }
                return cnt;
            }

            function toString(v) {
                return "[ " + v.x + ", " + v.y + ", " + v.z + " ]";
            }

            function render()
            {
                requestAnimationFrame(render);
                renderer.render(scene, camera);
                update();
            }

            function update()
            {
                geometry.verticesNeedUpdate = true;
                geometry.elementsNeedUpdate = true;
                geometry.colorsNeedUpdate = true;
                controls.update();
            }

            // Return unique values inside array
            Array.prototype.getUnique = function() {
                var u = {}, a = [];
                for (var i = 0, l = this.length; i < l; ++i) {
                    if (u.hasOwnProperty(this[i])) {
                        continue;
                    }
                    a.push(this[i]);
                    u[this[i]] = 1;
                }
                return a;
            };

             ////////////////////////////////////////////////////////////////////////////////
            // SAVE STL FILE //
            ////////////////////////////////////////////////////////////////////////////////

            function stringifyVertex(vec) {
                return "         vertex " + parseFloat(Math.round(vec.x * 100) / 100).toFixed(3) + " " + parseFloat(Math.round(vec.y * 100) / 100).toFixed(3) + " " + parseFloat(Math.round(vec.z * 100) / 100).toFixed(3) + "\n";
            }
            function stringifyNormal(vec) {
                return  parseFloat(Math.round(vec.x * 100) / 100).toFixed(3) + " " + parseFloat(Math.round(vec.y * 100) / 100).toFixed(3) + " " + parseFloat(Math.round(vec.z * 100) / 100).toFixed(3) + "\n";
            }

            // Given a THREE.Geometry, create an STL string
            function generateSTL(geo) {
                var vertices = geo.vertices;
                var tris = geo.faces;

                var stl = "solid\n";
                for (var i = 0; i < tris.length; i++) {
                    stl += ("   facet normal " + stringifyNormal(tris[i].normal));
                    stl += ("      outer loop\n");
                    stl += stringifyVertex(vertices[ tris[i].a ]);
                    stl += stringifyVertex(vertices[ tris[i].b ]);
                    stl += stringifyVertex(vertices[ tris[i].c ]);
                    stl += ("      endloop\n");
                    stl += ("   endfacet\n");
                }
                stl += ("endsolid");

                return stl;
            }

            // Use FileSaver.js 'saveAs' function to save the string
            function saveSTL( ) {
                var stlString = generateSTL(geometry);

                var blob = new Blob([stlString], {type: 'text/plain'});

                saveAs(blob,'solid'+'.stl');

            }
        </script>

    </body>
</html>
